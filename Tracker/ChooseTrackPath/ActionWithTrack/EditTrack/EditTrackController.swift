//  EditTrackController.swift

import UIKit

final class EditTrackController: UIViewController {
    
    var onDataCreated: (([TrackerCategory]) -> Void)? // Замыкание которое передает созданный трек в TrackersViewController через ChooseTrackController
    
    // MARK: Properties
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let table = UITableView()
    private var tableHeightConstraint: NSLayoutConstraint?
    
    // Properties for viewModel
    private var viewModel: TrackViewModel?
    private var dataBase = ["Категория", "Расписание"]
    private var daysForRepeatArray = String()
    private var categoryTitle = String() // для сохранения названия категории
    private var timeForRepeat: TimeTabel? // для сохранения расписания
    private var titleCategoryState: IndexPath? // хранит состояние выбранной категории
    internal var titleOfTrack = "" // для сохранения названия трека
    
    private var recordTitle = UILabel()
    private let titleTrackForSearch: String
    
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
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.backgroundColor = UIColor.grey.cgColor
        
        button.addAction(UIAction(handler: { [weak self] _ in
            
            if let timeTableIsnNil = self?.timeForRepeat {
            } else {
                self?.viewModel?.createTimeTableForOldValues()
            }
            
            guard let timeRepeate = self?.timeForRepeat, let mainTitle = self?.categoryTitle, let trackTitle = self?.titleOfTrack, let emojiToDrop = self?.emojiCollection?.chooseEmoji, let colorToDrop = self?.colorCollection?.chooseColor else { return }
            
            self?.viewModel?.updateValueAtDataBase(trackWithGoalTitle: self?.titleTrackForSearch ?? "Не нашли название трека",
                                                   newTimeTable: self?.timeForRepeat?.dayOfWeek,
                                                   newCategoryTitle: mainTitle,
                                                   newEmoji: emojiToDrop,
                                                   newTrackName: trackTitle,
                                                   newColor: colorToDrop)
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }()
    
    private var textFieldView: CustomTextFieldProtocol?
    private lazy var restrictionCount = {
        var label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        
        return label
    }()
    
    private let nameForNotification = NSNotification.Name(rawValue: "LabelUpdate")
    private var dataLoaded = false
    
    // Collections
    private var emojiCollection: EmojiCollectionProtocol?
    private var colorCollection: ColorCollectionProtocol?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureStandartViews()
        setupMainActorViews()
        addRecordTitle()
        scrollAddStack()
        addItemAtScroll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !dataLoaded && table.window != nil {
            loadActualDataForTableView()
            loadActualDays()
            dataLoaded = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    init(emojiCollection: EmojiCollectionProtocol, colorCollection: ColorCollectionProtocol, titleTrackForSearch: String) {
        self.titleTrackForSearch = titleTrackForSearch
        
        super.init(nibName: nil, bundle: nil)
        self.emojiCollection = emojiCollection
        self.colorCollection = colorCollection
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: MVVM bindings methods
    func initialize(viewModel: TrackViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.actualRecordCount = { [weak self] actualRecord in
            
            if let newSuf = Int(actualRecord) {
                let localizedString = String.localizedStringWithFormat(
                    NSLocalizedString("ending", comment: ""),
                    newSuf)
                self?.recordTitle.text = localizedString
            }
        }
        
        viewModel.goalTrack = { [weak self] trackName in
            self?.textFieldView?.editGoalOfTrack(with: trackName)
            self?.updateTitle(title: trackName)
        }
        
        viewModel.chooseEmoji = { [weak self] emoji in
            
            self?.emojiCollection?.updateChooseEmoji(at: emoji)
        }
        
        viewModel.chooseColor = { [weak self] newColor in
            self?.colorCollection?.updateChooseColor(at: newColor)
        }
        
        viewModel.regularTrackDidAdd = { [weak self] newTrack in
            self?.onDataCreated?(newTrack)
        }
        
        viewModel.titleOfTrack = { [weak self] newTitle in self?.updateTitle(title: newTitle)
        }
        
        viewModel.limitLabel = { [weak self] limitState in
            self?.updateLayout(showLimit: limitState)
        }
        
        viewModel.titleOfCategory = { [weak self] actualTitle in
            self?.categoryTitle = actualTitle
            // Обновляем ячейку - "Категория"
            self?.updateCategoriesCell(categoryArray: actualTitle)
        }
        
        viewModel.timeForRepeat = {[weak self] repeatTime in
            self?.timeForRepeat = repeatTime
        }
        
        viewModel.daysForRepeatArrayForController = { [weak self] stringWithDays in
            self?.daysForRepeatArray = stringWithDays
            self?.updateTimetableCell()
        }
        
        viewModel.categoryArrayForCellsUpdate = {[weak self] newArray in
            if newArray { self?.showChangesOfSettings() } // Отображаем полученные данные о категории и днях повторов
        }
        
        viewModel.indexPathChooseTitle = {[weak self] newState in
            self?.titleCategoryState = newState // состояние ячейки выбранного элемента на экране категории
        }
        
        viewModel.oldTimeTable = { [weak self] oldTime in
            self?.timeForRepeat = oldTime
        }
    }
    
    // MARK: Setup views methods
    private func setupMainActorViews(){
        textFieldView = TextFieldView(viewModel: viewModel ?? TrackViewModel(for: RegularTrackModel()))
        setupTable()
        setupCollections()
    }
    
    private func configureStandartViews(){
        view.backgroundColor = .white
        addNotification()
        setupKeyboard()
        setupNavigationTitle()
    }
    
    private func addNotification(){  // нотификация от Контроллера по выбору дней
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRepeatLabelDay),
                                               name: self.nameForNotification,
                                               object: nil)
    }
    
    private func addRecordTitle() {
        recordTitle.text = "Не прогрузилось"
        recordTitle.font = UIFont(name: "SFPro-Bold", size: 32)
        recordTitle.textAlignment = .center
        recordTitle.translatesAutoresizingMaskIntoConstraints = false
        viewModel?.getActualRecord(trackTitleForSearch: titleTrackForSearch)
        actualValueForTrack(title: titleTrackForSearch)
    }
    
    private func actualValueForTrack(title: String){
        viewModel?.getActualTrackGoal(forTrack: title)
        viewModel?.getActualEmoji(forTrack: title)
        viewModel?.getActualColor(forTrack: title)
    }
    
    private func loadActualDataForTableView(){
        guard table.window != nil else { return }
        viewModel?.loadActulCategoryTitle(trackTitle: titleTrackForSearch)
    }
    
    private func loadActualDays(){
        viewModel?.loadActualDays(trackTitle: titleTrackForSearch)
    }
    
    private func setupNavigationTitle(){
        navigationItem.title = ""
        
        let titleContainer = UIView()
        navigationItem.titleView = titleContainer
        let titleLabel = UILabel()
        
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 17)
        titleLabel.text = "Редактирование привычки"
        
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
        scrollView.contentInsetAdjustmentBehavior = .never
        
        //Scroll
        scrollView.addSubview(stackView)
        scrollView.addSubview(recordTitle)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 3. Добавляем констрейнты
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            recordTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            recordTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recordTitle.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: 80),
            
            // StackView внутри ScrollView
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32) // Ширина с учетом отступов
        ])
    }
    
    private func addItemAtScroll(){
        guard let textFieldView else { return }
        
        let buttonStack = createButtonStack()
        stackView.addArrangedSubview(recordTitle)
        stackView.addArrangedSubview(textFieldView)
        stackView.addArrangedSubview(restrictionCount)
        stackView.addArrangedSubview(table)
        stackView.addArrangedSubview(emojiCollection?.emojiCollection ?? UICollectionView())
        stackView.addArrangedSubview(colorCollection?.colorCollection ?? UICollectionView())
        stackView.addArrangedSubview(buttonStack)
        
        restrictionCount.isHidden = true
    }
    
    private func createButtonStack() -> UIStackView {
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

extension EditTrackController {
    
    // MARK: add collections
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
        
        // Дебаг-рамки
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
extension EditTrackController: UITableViewDataSource, UITableViewDelegate {
    
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
        tableHeightConstraint?.constant = table.contentSize.height
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
            guard let viewModel else { return }
            
            let createCategoryVC = AddNewCategoryController(transitionNewCategoryTitleToViewModel: viewModel, selectedIndexPath: titleCategoryState ?? nil)
            let createCategoryVM = CreateCategoryViewModel(model: CreateCategoryModel())
            createCategoryVC.initialize(viewModel: createCategoryVM)
            
            navigationController?.pushViewController(createCategoryVC, animated: true)
            
        } else if dataBase[indexPath.row] == "Расписание" {
            let chooseDay = ChooseDayController()
            navigationController?.pushViewController(chooseDay, animated: true)
        }
    }
}

// MARK: Methods calls trackViewModel
extension EditTrackController: TextFieldControllerProtocol {
    
    // метод обновляет начзвание трека - реагирует на байдинг titleOfTrack
    func updateTitle(title: String){
        titleOfTrack = title
        if !title.isEmpty {
            saveButton.layer.backgroundColor = UIColor.blackDay.cgColor
            saveButton.isEnabled = true
        } else {
            saveButton.layer.backgroundColor = UIColor.grey.cgColor
            saveButton.isEnabled = false
        }
    }
    
    // Метод обновляет высоту строк при показе ограничителя - реагирует на байдинг limitLabel
    func updateLayout(showLimit: Bool) {
        guard let textFieldView else { return }
        
        restrictionCount.isHidden = !showLimit
        UIView.animate(withDuration: 0.3) {
            self.stackView.setCustomSpacing(showLimit ? 8 : 24, after: textFieldView)
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: Methods update the cells "Категории", "Расписание"
extension EditTrackController {
    
    // Метод обрабатывает значение с днями недели от ChooseDayController
    @objc private func updateRepeatLabelDay(_ notification: Notification){
        
        guard let userInfo = notification.userInfo as? [String: Any] else {
            print("[CreateRegularTrackController]: updateRepeatLabelDay - Ошибка при получении данных")
            return
        }
        viewModel?.updateCategoryTitleAndRepeatDays(userInput: userInfo)
    }
    
    private func showChangesOfSettings(){
        table.performBatchUpdates {
            // Обновляем ячейку - "Расписание"
            updateTimetableCell()
            updateTableHeight()
        }
    }
    
    private func updateTimetableCell(){
        table.visibleCells.forEach { cell in
            
            guard let customCell = cell as? RegularTrackCell,
                  let indexPath = table.indexPath(for: customCell),
                  dataBase[indexPath.row].prefix(10) == "Расписание" else { return }
            
            customCell.configurateWith(newData: daysForRepeatArray)
        }
    }
    // Метод обновлнеyия визуальной составяляющей ячейки
    private func updateCategoriesCell(categoryArray:String){
        table.visibleCells.forEach { cell in
            guard let customCell = cell as? RegularTrackCell,
                  let indexPath = table.indexPath(for: customCell),
                  dataBase[indexPath.row].prefix(9) == "Категория" else { return }
            
            customCell.configurateWith(newData: categoryArray)
        }
    }
}

// Keyboard methods
extension EditTrackController {
    private func setupKeyboard(){
        let tapCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        tapCloseKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapCloseKeyboard)
    }
    
    // Метод просит TextField считать данные после закрытия клавиатуры
    @objc private func closeKeyBoard(){
        view.endEditing(true)  // Скрывает клавиатуру для всех полей
        textFieldView?.updateTitleWhenCloseTheKeyboard()
    }
}
