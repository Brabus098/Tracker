//  CreateRegularTrackController.swift

import UIKit

final class CreateRegularTrackController: UIViewController {
    
    // Замыкание которое передает созданный трек в TrackersViewController через ChooseTrackController
    var onDataCreated: (([TrackerCategory]) -> Void)?
    
    // MARK: Properties
    
    // Констрейнты для изменения отступовв в случае превышения 38 символов на ввод
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private let table = UITableView()
    private let nameForNotification = NSNotification.Name(rawValue: "LabelUpdate")
    
    // MARK: DataBase properties
    private var dataBase = ["Категория", "Расписание"]
    private var daysForRepeatArray = [String]()
    private var categoryForTracks = [TrackerCategory]() // для сохранения новых трекеров и их последующей передачи
    private var categoryTitle = String() // для сохранения названия категории
    private var timeForRepeat: TimeTabel? // для сохранения расписания
    private var titleOfTrack = "" // для сохранения названия трека
    
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
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
            guard let timeRepeate = self?.timeForRepeat else { return }
            
            // Сохраняем в модель
            self?.categoryForTracks.append(TrackerCategory(title: self?.categoryTitle ?? "",
                                                           trackerArray: [Tracker(id: UInt.random(in: 1...100),
                                                                                  name: self?.titleOfTrack ?? "",
                                                                                  color: .green,
                                                                                  emoji: "",
                                                                                  timeTable: timeRepeate)]))
            self?.categoryForTracks.forEach{ print($0) }
            print("Начинаем отправку данных")
            self?.onDataCreated?(self?.categoryForTracks ?? [TrackerCategory]())
            
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var nameOfTrack = {
        let textField = UITextView()
        
        //                textField.leftView = paddingView
        //                textField.leftViewMode = .always
        //                textField.placeholder = "Введите название трека"
        textField.textContainerInset = UIEdgeInsets(top: 28, left: 16, bottom: 0, right: 62)
        textField.font = UIFont(name: "SFPro-Regular", size: 17)
        textField.backgroundColor = .backgroundDay
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private lazy var cleanTextButton = {
        let cleanButton = UIButton()
        
        cleanButton.setImage(UIImage(named: "CleanButton"), for: .normal)
        cleanButton.isHidden = true
        cleanButton.addAction(UIAction(handler: {[weak self] _ in
            self?.placeholderForTextView.isHidden = false
            cleanButton.isHidden = true
            self?.nameOfTrack.text = nil
            self?.restrictionCount.isHidden = true
            self?.topConstraint?.constant = 24
            self?.bottomConstraint?.constant = -430
            
            UIView.animate(withDuration: 0.1) {
                self?.view.layoutIfNeeded()
            }
        }), for: .touchUpInside)
        
        view.addSubview(cleanButton)
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        
        return cleanButton
    }()
    
    private lazy var placeholderForTextView = {
        let text = UILabel()
        text.text = "Введите название трека"
        text.font = UIFont(name: "SFPro-Regular", size: 17)
        text.textColor = .lightGray
        text.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text)
        return text
    }()
    
    private lazy var restrictionCount = {
        var label = UILabel()
        label.text = "Ограничение 38 символов"
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.table.centerXAnchor),
            label.topAnchor.constraint(equalTo: self.nameOfTrack.bottomAnchor, constant: 9),
            table.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24)
        ])
        label.isHidden = false
        
        topConstraint?.constant = 62
        bottomConstraint?.constant = -380
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        return label
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setupTable()
        constraintForViews()
        addNotification()
    }
    
    // MARK: Setup views methods
    private func addNotification(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRepeatLabelDay),
                                               name: self.nameForNotification,
                                               object: nil)
    }
    
    private func configureViews(){
        view.backgroundColor = .white
        setupNameOfTrackLabel()
        setupKeyboard()
        setupNavigationTitle()
    }
    
    private func setupNameOfTrackLabel(){
        
        nameOfTrack.delegate = self
        //        nameOfTrack.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        //        nameOfTrack.addTarget(self, action: #selector(changeValue), for: .editingChanged)
    }
    
    private func setupKeyboard(){
        let tapCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        tapCloseKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapCloseKeyboard)
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
    
    @objc private func closeKeyBoard(){
        cleanTextButton.isHidden = true
        view.endEditing(true)  // Скрывает клавиатуру для всех полей
        titleOfTrack = self.nameOfTrack.text
    }
    
    @objc private func editingDidEnd() {
        cleanTextButton.isHidden = true
    }
    
    private func setupTable(){
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.separatorStyle = .singleLine // Включаем разделители
        table.separatorColor = .lightGray // Цвет как у системы
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Стандартные отступы
        
        //Временно:
        //                        table.layer.borderWidth = 2
        //                        table.layer.borderColor = UIColor.red.cgColor
        
        // Убираем верхний разделитель таблицы
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        table.isUserInteractionEnabled = true
        table.dataSource = self
        table.delegate = self
        table.register(RegularTrackCell.self, forCellReuseIdentifier: "RegularTrackCell")
    }
    
    private func constraintForViews(){
        
        NSLayoutConstraint.activate([
            nameOfTrack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameOfTrack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameOfTrack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            nameOfTrack.heightAnchor.constraint(equalToConstant: 75),
            
            cleanTextButton.centerYAnchor.constraint(equalTo: nameOfTrack.centerYAnchor),
            cleanTextButton.topAnchor.constraint(equalTo: nameOfTrack.topAnchor, constant: 29),
            cleanTextButton.trailingAnchor.constraint(equalTo: nameOfTrack.trailingAnchor, constant: -12),
            
            placeholderForTextView.leadingAnchor.constraint(equalTo: nameOfTrack.leadingAnchor, constant: 20),
            placeholderForTextView.topAnchor.constraint(equalTo: nameOfTrack.topAnchor, constant: 27),
            placeholderForTextView.bottomAnchor.constraint(equalTo: nameOfTrack.bottomAnchor, constant: -26),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            saveButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            
            table.leadingAnchor.constraint(equalTo: nameOfTrack.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: nameOfTrack.trailingAnchor),
        ])
        
        let tableHeightConstraint = table.heightAnchor.constraint(greaterThanOrEqualToConstant: 170)
        tableHeightConstraint.priority = .defaultLow
        tableHeightConstraint.isActive = true

       
        let maxHeightConstraint = table.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.5)
        maxHeightConstraint.isActive = true
        self.topConstraint = table.topAnchor.constraint(equalTo: nameOfTrack.bottomAnchor, constant: 24)
        self.topConstraint?.isActive = true
        self.bottomConstraint?.isActive = true
    }
}

// MARK: Setup TableView
extension CreateRegularTrackController: UITableViewDataSource, UITableViewDelegate {
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

// MARK: UITextView Delegate
extension CreateRegularTrackController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeholderForTextView.isHidden = true
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        changeValue()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {  // Если нажат Return
            textView.resignFirstResponder()
            cleanTextButton.isHidden = true
            titleOfTrack = text
            titleOfTrack = self.nameOfTrack.text
            return false
        }
        return true
    }
}

// MARK:
extension CreateRegularTrackController {
    
    // метод ограничивающий количество символов на вввод
    @objc private func changeValue(){
        if let textCount = nameOfTrack.text?.count {
            
            if textCount == 0 && nameOfTrack.text.isEmpty{
                placeholderForTextView.isHidden = false
                cleanTextButton.isHidden = true
                
            } else if textCount > 0 {
                print("Видна")
                placeholderForTextView.isHidden = true
                saveButton.backgroundColor = .blackDay
                cleanTextButton.isHidden = false
            }
            
            if textCount > 38 {
                restrictionCount.isHidden = false
                restrictionCount.textColor = .red
                
                topConstraint?.constant = 62
                bottomConstraint?.constant = -380
                
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
                
            } else {
                restrictionCount.isHidden = true
                topConstraint?.constant = 24
                bottomConstraint?.constant = -495
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
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


extension CreateRegularTrackController: UITextFieldDelegate{
    //         //Метод закрывает клавиатуру
    //            func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //                textField.resignFirstResponder()
    //                return true
    //            }
    //
}

