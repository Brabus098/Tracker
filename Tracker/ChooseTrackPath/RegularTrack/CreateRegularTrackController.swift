//  CreateRegularTrackController.swift

import UIKit

final class CreateRegularTrackController: UIViewController {
    
    // Замыкание которое передает созданный трек в TrackersViewController через ChooseTrackController
    var onDataCreated: (([TrackerCategory]) -> Void)?
    
    // MARK: Properties
    
    // Main properties
    let stackView = UIStackView()
    let scrollView = UIScrollView()
    private let table = UITableView()
    var textFieldView: CustomTextFieldProtocol?
    weak var track: TrackCollectionProtocol? // ссылка на коллекцию


    // Collections
    var emojiCollection: EmojiCollectionProtocol?
    var colorCollection: ColorCollectionProtocol?
    
    private let nameForNotification = NSNotification.Name(rawValue: "LabelUpdate")
    private var tableHeightConstraint: NSLayoutConstraint?
    
    // MARK: DataBase properties
    private var dataBase = ["Категория", "Расписание"]
    private var daysForRepeatArray = [String]()
    private var categoryForTracks = [TrackerCategory]() // для сохранения новых трекеров и их последующей передачи
    private var categoryTitle = String() // для сохранения названия категории
    private var timeForRepeat: TimeTabel? // для сохранения расписания
    internal var titleOfTrack = "" // для сохранения названия трека
    
    private lazy var cancelButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        
        button.addAction(UIAction(handler: { [weak self] _ in
            print("Отмена")
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }()
    
    private lazy var saveButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.backgroundColor = UIColor.grey.cgColor
        
        button.addAction(UIAction(handler: { [weak self] _ in
            let emoji = self?.emojiCollection?.chooseEmoji
            let color = self?.colorCollection?.chooseColor
            
            // MARK: СДЕЛАТЬ ПРОВЕРКУ НА СУЩЕСТВОВАНИЕ ТРЕКА ИЗ БД
            
            guard let timeRepeate = self?.timeForRepeat, let emoji, let color else { return }
            
            
            // Сохраняем в модель
            self?.categoryForTracks.append(TrackerCategory(title: self?.categoryTitle ?? "",
                                                           trackerArray: [Tracker(id: UInt.random(in: 1...10000),
                                                                                  name: self?.titleOfTrack ?? "",
                                                                                  color: color,
                                                                                  emoji: emoji,
                                                                                  timeTable: timeRepeate)]))
            self?.categoryForTracks.forEach{ print($0) }
            print("Начинаем отправку данных")
            self?.onDataCreated?(self?.categoryForTracks ?? [TrackerCategory]())
            
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }()
    
    private lazy var restrictionCount = {
        var label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
    
        return label
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureStandartViews()
        setupMainActorViews()
        scrollAddStack()
        addItemAtScroll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("Доступная высота экрана:", view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        print("Общая требуемая высота:", stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    init(emojiCollection: EmojiCollectionProtocol, colorCollection: ColorCollectionProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.emojiCollection = emojiCollection
        self.colorCollection = colorCollection
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup views methods
    
    private func setupMainActorViews(){
        textFieldView = TextFieldView(controller: self)
        setupTable()
        setupCollections()
    }
    
    private func configureStandartViews(){
        view.backgroundColor = .white
        addNotification()
        setupKeyboard()
        setupNavigationTitle()
    }
    
    private func addNotification(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRepeatLabelDay),
                                               name: self.nameForNotification,
                                               object: nil)

    }
   
    private func setupNavigationTitle(){
        navigationItem.title = ""
    
        let titleContainer = UIView()
        navigationItem.titleView = titleContainer
        let titleLabel = UILabel()
        
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 17)
        titleLabel.text = "Новая привычка"
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 20)
        ])
        navigationItem.hidesBackButton = true
    }
    
    private func scrollAddStack(){
        
        // Stack
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never // MARK:

        //Scroll
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 3. Добавляем констрейнты
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),// длинна скролла
            
            // StackView внутри ScrollView
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Важно для вертикального скролла:
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32) // Ширина с учетом отступов
        ])
    }
    
    private func addItemAtScroll(){
        guard let textFieldView else { return }
        
        let buttonStack = createButtonStack()

        stackView.addArrangedSubview(textFieldView)
        stackView.addArrangedSubview(restrictionCount)
        stackView.addArrangedSubview(table)
        stackView.addArrangedSubview(emojiCollection?.emojiCollection ?? UICollectionView())
        stackView.addArrangedSubview(colorCollection?.colorCollection ?? UICollectionView())
        stackView.addArrangedSubview(buttonStack)
        
        restrictionCount.isHidden = true
    }
    
    private func createButtonStack() -> UIStackView{
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal // Горизонтальное расположение
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .center // Выравнивание по центру (по вертикали)
        buttonStack.spacing = 8 // Отступ между кнопками

        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(saveButton)
        return buttonStack
    }
}

// MARK: add collections

extension CreateRegularTrackController {
    
    private func setupCollections() {
        guard let emojiCollection, let colorCollection else { return }
        
        emojiCollection.configurateEmojiCollection()
        colorCollection.configColorCollection()
        
        let emojiC = emojiCollection.emojiCollection
        let colorC = colorCollection.colorCollection
        
        emojiC.isScrollEnabled = false
        colorC.isScrollEnabled = false
        
        emojiC.translatesAutoresizingMaskIntoConstraints = false
        colorC.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Дебаг-рамки (можно удалить позже)
        //        emojiC.layer.borderWidth = 2
        //        emojiC.layer.borderColor = UIColor.red.cgColor
        //        colorC.layer.borderWidth = 2
        //        colorC.layer.borderColor = UIColor.green.cgColor
        
        NSLayoutConstraint.activate([
            emojiC.heightAnchor.constraint(equalToConstant: 210),
            colorC.heightAnchor.constraint(equalToConstant: 210)
        ])
    }
}

// MARK: Setup TableView
extension CreateRegularTrackController: UITableViewDataSource, UITableViewDelegate {
    
 
    private func setupTable(){
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.separatorStyle = .singleLine // Включаем разделители
        table.separatorColor = .lightGray // Цвет как у системы
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Стандартные отступы
        table.isScrollEnabled = false
        
//        //Временно:
//        table.layer.borderWidth = 2
//        table.layer.borderColor = UIColor.purple.cgColor
        
        // Убираем верхний разделитель таблицы
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        table.isUserInteractionEnabled = true
        table.dataSource = self
        table.delegate = self
        table.register(RegularTrackCell.self, forCellReuseIdentifier: "RegularTrackCell")
    
        table.estimatedRowHeight = 75  // Примерная высота (для оптимизации)
        table.rowHeight = UITableView.automaticDimension  // Автоматический расчёт
        
        // Добавляем констрейнт по высоте
        tableHeightConstraint = table.heightAnchor.constraint(equalToConstant: 1)
        tableHeightConstraint?.isActive = true

    }
    
    private func updateTableHeight() {
        table.layoutIfNeeded()
        print("Высота контент сайз - ", table.contentSize.height)
        tableHeightConstraint?.constant = table.contentSize.height
        print("Высота контент сайз - ", table.contentSize.height)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataBase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RegularTrackCell", for: indexPath) as? RegularTrackCell else { return UITableViewCell()}
        
        cell.configurateText(ForLabel: dataBase[indexPath.row])
        cell.backgroundColor = UIColor(named: "BackgroundDay")
        
        // Для первой ячейки - разделитель будет снизу
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
        }
        // Для последней ячейки - убираем разделитель
        else if indexPath.row == dataBase.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if dataBase[indexPath.row] == "Категория" {
            
        } else if dataBase[indexPath.row] == "Расписание" {
            let chooseDay = ChooseDayController()
            navigationController?.pushViewController(chooseDay, animated: true)
        }
    }
}

// MARK: TextFieldControllerProtocol
extension CreateRegularTrackController: TextFieldControllerProtocol {
    func updateTitle(title: String){
        titleOfTrack = title
        if !title.isEmpty {
            saveButton.layer.backgroundColor = UIColor.blackDay.cgColor
            saveButton.isEnabled = true
        } else {
            saveButton.layer.backgroundColor = UIColor.grey.cgColor
            saveButton.isEnabled = false

        }
        print("Приняли тайтл - \(titleOfTrack)")
    }
    
    func updateLayout(showLimit: Bool) {
        guard let textFieldView else { return }
        
        restrictionCount.isHidden = !showLimit
        UIView.animate(withDuration: 0.3) {
            self.stackView.setCustomSpacing(showLimit ? 8 : 24, after: textFieldView)
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupKeyboard(){
        let tapCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        tapCloseKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapCloseKeyboard)
    }
    
    @objc private func closeKeyBoard(){
        view.endEditing(true)  // Скрывает клавиатуру для всех полей
        print("Метод скрытия сработал")
        textFieldView?.updateTitleWhenCloseTheKeyboard()
    }
}

// MARK: Business Logic
extension CreateRegularTrackController {
    
    // Метод обрабатывает значение с днями недели от ChooseDayController
    @objc private func updateRepeatLabelDay(_ notification: Notification){
        
        guard let userInfo = notification.userInfo as? [String: Any] else {
            print("[CreateRegularTrackController]: updateRepeatLabelDay - Ошибка при получении данных")
            return
        }
        
        let daysDictionary = userInfo
        let categoryArray = [daysDictionary["Категория"] as? String ?? "[CreateRegularTrackController]:updateRepeatLabelDay - Неизвестная категория]"]
        categoryTitle = daysDictionary["Категория"] as? String ?? "[CreateRegularTrackController]:updateRepeatLabelDay - Неизвестная категория]"
        
        self.daysForRepeatArray.removeAll() // удаляем значения чтобы задать повторно
        createArrayWithDaysOfWeek(data: daysDictionary) // создаем массив с полученными днями недели
        addShortNameDaysOFWeek() // Наполняем массив с сокращенными повторов
        showChangesOfSettings(array: categoryArray) // Отображаем полученные данные о категории и днях повторов
    }
    
    private func showChangesOfSettings(array:[String]){
        table.performBatchUpdates {
            // Обновляем ячейку - "Расписание"
            updateTimetableCell()
            // Обновляем ячейку - "Категория"
            updateCategoriesCell(categoryArray: array)
            // Обновляем размер таблицы
            updateTableHeight()
        }
    }
    
    private func createArrayWithDaysOfWeek(data:[String : Any] ){
        data.forEach { key, value in
            guard value as? Bool ?? false else { return } // TODO: Пропускаем false также проверяет категорию, вернуть на Bool когда появится контроллер выбора категорий
            
            let addValue: String
            
            switch key {
            case "Понедельник": addValue = "Пн"
            case "Вторник": addValue = "Вт"
            case "Среда": addValue = "Ср"
            case "Четверг": addValue = "Чт"
            case "Пятница": addValue = "Пт"
            case "Суббота": addValue = "Сб"
            case "Воскресенье": addValue = "Вс"
                
            default: return // Пропускаем неизвестные ключи
            }
            daysForRepeatArray.append(addValue)
        }
    }
    
    private func addShortNameDaysOFWeek(){
        var actualDaysArray = [WeekDay]()
        daysForRepeatArray.forEach { title in
            if let actualDay = WeekDay(rawValue: title) {
                actualDaysArray.append(actualDay)
            }
        }
        // Задаем время для повтора
        timeForRepeat = (TimeTabel(dayCount: 0, dayOfWeek: actualDaysArray))
    }
    
    private func updateTimetableCell(){
        table.visibleCells.forEach { cell in
            
            guard let customCell = cell as? RegularTrackCell,
                  let indexPath = table.indexPath(for: customCell),
                  dataBase[indexPath.row].prefix(10) == "Расписание" else { return }
            
            customCell.configurateWith(newData: daysForRepeatArray, updateWeekDays: true)
        }
    }
    
    private func updateCategoriesCell(categoryArray:[String]){
        table.visibleCells.forEach { cell in
            guard let customCell = cell as? RegularTrackCell,
                  let indexPath = table.indexPath(for: customCell),
                  dataBase[indexPath.row].prefix(9) == "Категория" else { return }
            
            customCell.configurateWith(newData: categoryArray, updateWeekDays: false)
        }
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
