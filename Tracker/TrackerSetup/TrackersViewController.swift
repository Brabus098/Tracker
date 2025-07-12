//  TrackersViewController.swift

import UIKit

final class TrackersViewController: UIViewController {
    
    weak var track: TrackCollectionProtocol? // ссылка на коллекцию
    
    private lazy var searchBar = {
        let searchBar = UISearchBar()
        add(newView: searchBar)
        
        searchBar.placeholder = "Поиск"
        searchBar.removeSystemPadding()
        searchBar.searchTextField.font = UIFont(name: "SFPro-Regular", size: 17)
        
        searchBar.layer.borderWidth = 0
        searchBar.layer.masksToBounds = true
        
        return searchBar
    }()
    
    private lazy var questionLabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        
        add(newView: label)
        
        return label
    }()
    
    private lazy var mainTrackLabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textAlignment = .left
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        add(newView: label)
        
        return label
    }()
    
    private let noTrackImageView = UIImageView()
    private let datePiker = UIDatePicker()
    
    // MARK: DataBase propertyes
    private  var currentDate: Date = Date()
    private var categories = [TrackerCategory]() // массив со всеми треками
    private var trackByDayDictionary: [WeekDays: Set<UInt>] = [WeekDays.Monday: Set<UInt>(), WeekDays.Tuesday: Set<UInt>(), WeekDays.Wednesday: Set<UInt>(), WeekDays.Thursday: Set<UInt>(), WeekDays.Friday: Set<UInt>(), WeekDays.Saturday: Set<UInt>(), WeekDays.Sunday: Set<UInt>()] // Словраь с id привязанный к дням недели
    private var completedTrackers = [TrackerRecord]() //  массив с выполнеными треками
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBaseView()
        setupImageView()
        setupConstraint()
        setUpNavigationPlusButton()
        setupDatePicker()
        setupStartView()
    }
    
    init(track: TrackCollectionProtocol) {
        self.track = track
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup Views
    private func setupCollection(dataBase: [TrackerCategory]){
        guard let track else { return }
        track.configure(collection: dataBase, controllerForCollection: self, completedTrackers: completedTrackers)
        
        add(newView: track.collection)
        
        NSLayoutConstraint.activate([
            track.collection.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            track.collection.leadingAnchor.constraint(equalTo: view.leadingAnchor ),
            track.collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            track.collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupDatePicker(){
        datePiker.datePickerMode = .date
        datePiker.preferredDatePickerStyle = .compact
        datePiker.locale = Locale(identifier: "ru_RU")
        
        setupDateFor(piker: datePiker)
        
        datePiker.addTarget(self, action: #selector(actionWhitDatePicker(_:)), for: .valueChanged)
        addToNavBar(piker: datePiker)
    }
    
    private func setupDateFor(piker: UIDatePicker){
        let date = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: date)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: date)
        
        datePiker.minimumDate = minDate
        datePiker.maximumDate = maxDate
    }
    
    private func addToNavBar(piker: UIDatePicker){
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        navigationBar.addSubview(piker)
        piker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            piker.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -16),
            piker.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor)
        ])
    }
    
    private func setupBaseView(){
        view.backgroundColor = .white
    }
    
    private func setupImageView(){
        add(newView: noTrackImageView)
        noTrackImageView.contentMode = .scaleAspectFit
        noTrackImageView.image = UIImage(named: "noTrackImageLogo")
    }
    
    private func setUpNavigationPlusButton(){
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        let button = UIButton()
        navigationBar.addSubview(button)
        
        button.setImage(UIImage(named: "plusTarget"), for: .normal)
        button.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: 6),
            button.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor)
        ])
    }
    
    @objc private func leftButtonTapped(){
        let createTrackController = ChooseTrackController()
        createTrackController.parentTrackerVC = self
        let trackNavigation = UINavigationController(rootViewController: createTrackController)
        present(trackNavigation, animated: true)
    }
    
    private func setupConstraint(){
        
        NSLayoutConstraint.activate([
            
            // Central image
            noTrackImageView.widthAnchor.constraint(equalToConstant: 80),
            noTrackImageView.heightAnchor.constraint(equalToConstant: 80),
            noTrackImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTrackImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Label after image
            questionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            questionLabel.topAnchor.constraint(equalTo: noTrackImageView.bottomAnchor, constant: 8),
            
            // Label with Track title
            mainTrackLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            mainTrackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainTrackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Search Bar
            searchBar.topAnchor.constraint(equalTo: mainTrackLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: mainTrackLabel.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0)
        ])
    }
}

// MARK: Methods with movement logic
extension TrackersViewController {
    
    // Метод вызывается при добавлении нового трека и при первом запуске
    private func setupStartView(){
        
        if !categories.isEmpty{
            print("Категория заполнена")
            let actualForTodayDataArray = chooseActualDataForPresent() // формируем актуальный масиив с треками на выбранную дату
            makeCollectionInvisible(ifEmpty: actualForTodayDataArray) // скрываем коллекцию в случае если на ыывбранный день нету трека
            
            setupCollection(dataBase: actualForTodayDataArray) // добавляем коллекцию если еще не добавлена
            track?.reloadData(with: actualForTodayDataArray, and: completedTrackers, choseDate: currentDate) // перезагружаем данные с учетом всех обновленных данных
            
        } else { print("Категория не заполнена") }
    }
    
    // Метод срабатывает при изменении даты в датапикере
    @objc private func actionWhitDatePicker(_ sender: UIDatePicker){
        
        currentDate = sender.date // меняем дату на выбранную
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        
        guard let selectedFormattedDate = WeekDays(rawValue: weekday) else {
            print("Ошибка: не удалось определить день недели")
            return
        }
        
        let filteredData = chooseActualDataForPresent()
        makeCollectionInvisible(ifEmpty: filteredData)
        track?.reloadData(with: filteredData, and: completedTrackers, choseDate: currentDate)
    }
    
    private func makeCollectionInvisible(ifEmpty: [TrackerCategory]){
        if ifEmpty.isEmpty {
            track?.collection.layer.opacity = 0
        } else {
            track?.collection.layer.opacity = 1
        }
    }
}

// MARK: Methods create actual tracks on selected date
extension TrackersViewController {
    
    // Метод формирует актуальный масcив с треками на выбраную дату
    private func chooseActualDataForPresent() -> [TrackerCategory]{
        
        let calendarCurrent = Calendar.current
        let weekday = calendarCurrent.component(.weekday, from: currentDate) // определяем день недели для выбранной даты
        let selectedFormattedDate = WeekDays(rawValue: weekday) // определяем номер дня недели
        
        let actualArrayWithData = categories // копируем весь масив с данными
        var newData = [TrackerCategory]()
        
        for actualTrackForDay in trackByDayDictionary { // Проходимся по словарю с индексами по дням
            
            if actualTrackForDay.key == selectedFormattedDate && !actualTrackForDay.value.isEmpty { // если сегодняшний день == ключу и множество не пустове
                let setForActualDay = actualTrackForDay.value // множество с нужными ключами
                
                for array in actualArrayWithData { // Проходим по всем трекам и убираем лишние треки
                    
                    let totalCategory = array.trackerArray.filter { setForActualDay.contains($0.id) } // оставляем только те категории которые содержат нужный id
                    if !totalCategory.isEmpty {
                        newData.append(TrackerCategory(title: array.title, trackerArray: totalCategory)) // добавляем
                    }
                }
            } else { continue } // иначе пропускаем
        }
        return newData // возвращаем отфильтрованный список для currentDate
    }
    
    // Достаем из categories дни недели в которые повторяем треки и передаем в trackByDayDictionary
    private func showTrackOnSelectedDate(selectedDate: WeekDays){
        
        var trackForShow = Set<UInt>() // Храним актуальные id для текущего дня
        
        categories.forEach { category in // Проходимся по категориям
            for i in category.trackerArray { // Проходимся по массиву с терками внутри категории
                
                let arrayWithDaysOfWeek = i.timeTable.dayOfWeek
                let id = i.id
                
                for selectDay in arrayWithDaysOfWeek { // Достаем дни для каждого id
                    
                    switch selectDay {
                        
                    case .Monday where (selectedDate.rawValue == 2):
                        trackForShow.insert(id)
                    case .Tuesday where (selectedDate.rawValue == 3):
                        trackForShow.insert(id)
                    case .Wednesday where (selectedDate.rawValue == 4):
                        trackForShow.insert(id)
                    case .Thursday where (selectedDate.rawValue == 5):
                        trackForShow.insert(id)
                    case .Friday where (selectedDate.rawValue == 6):
                        trackForShow.insert(id)
                    case .Saturday where (selectedDate.rawValue == 7):
                        trackForShow.insert(id)
                    case .Sunday where (selectedDate.rawValue == 1):
                        trackForShow.insert(id)
                    default :
                        break
                    }
                }
            }
        }
        
        for (key, value) in trackByDayDictionary{ // добавляем id треков для выбранного дня
            if key == selectedDate {
                trackByDayDictionary[selectedDate] = trackForShow.union(value)
            }
        }
    }
}

extension TrackersViewController: TrackersViewControllerProtocol {
    
    // Метод принимает данные с формы через замыкание
    func updateCategoriesArray(new array: [TrackerCategory]) {
        
        let choseCategory = array[0]
        
        // Если категория есть добавляем новый трек туда
        if let index = categories.firstIndex(where: {$0.title == choseCategory.title}){
            
            var addNewTrack = categories[index].trackerArray
            addNewTrack.append(contentsOf: choseCategory.trackerArray)
            
            categories[index] = TrackerCategory(title: choseCategory.title,
                                                trackerArray: addNewTrack)
            print("Добавили треки в существующую категорию: \(choseCategory.title)")
            
            // Если нету создаем новую категорию с новым треком
        } else {
            categories.append(choseCategory)
            print("Добавили новую категорию - \(choseCategory)")
        }
        
        updateIndex() // обновляем индексы
        setupStartView()
    }
    
    // Обновляем массив с актуальными индексам
    private func updateIndex(){
        for i in 1..<9 {
            let selectedFormattedDate = WeekDays(rawValue: i)
            if let selectedFormattedDate{
                showTrackOnSelectedDate(selectedDate: selectedFormattedDate)
            }
        }
    }
}

// MARK: TrackCollectionActionDelegate
extension TrackersViewController: TrackCollectionActionDelegate {
    
    enum ActionWithArray{
        case remove
        case add
    }
    
    // Метод вызываемый делегирующим объектом(коллекцией) реагирует на изменение состояния кнопки в ячейки
    func didCompleteTracker(_ trackerId: UInt) {
        
        let todayDateArray = currentDate.formatted()
        // Ищем в оригинальном массиве, где находится trackerId
        guard let (sectionIndex, itemIndex) = findIndexPath(for: trackerId) else {
            print("Ошибка: не нашли trackerId в categories")
            return
        }
        
        correctedTrackersArray(
            actualDate: todayDateArray,
            actualId: trackerId,
            section: sectionIndex,
            item: itemIndex
        ) // изменяем счетчик в ячейке
        
        let filteredData = chooseActualDataForPresent()
        
        track?.reloadData(with: filteredData, and: completedTrackers, choseDate: currentDate)
        
    }
    
    // Метод определяет индексы для ячейки
    private func findIndexPath(for trackerId: UInt) -> (Int, Int)? {
        for (sectionIndex, category) in categories.enumerated() {
            if let itemIndex = category.trackerArray.firstIndex(where: { $0.id == trackerId }) {
                return (sectionIndex, itemIndex)
            }
        }
        return nil
    }
    
    // Метод определяет действие(+/-) в зависимости от наличия выбарнной даты
    private func correctedTrackersArray(actualDate: String, actualId: UInt, section: Int , item: Int ){
        
        // Если элемент с таким id есть в выполненных треках и в нем есть выбранная дата, значит выбрано действие - "Трек не выполнен"
        if completedTrackers.contains(where: { $0.id == actualId  && $0.trackCompletionDate.contains(where: {$0 == actualDate }) }){
            
            guard let index = completedTrackers.firstIndex(where: {$0.id == actualId}) else { return }
            
            // Понижаем каунтер для общей модели
            correctedCategoriesCounter(section: section, item: item, action: ActionWithArray.remove)
            
            // Удаляем лишние даты или весь рекорд
            removeDateInTrackerArray(actualDate: actualDate, actualId: actualId, indexElement: index)
            
            print("Текущий массив после удаления", completedTrackers)
            
            // Если id есть,а выбранной даты нету
        } else if completedTrackers.contains(where: { $0.id == actualId  && $0.trackCompletionDate.contains(where: {$0 != actualDate }) }){
            
            guard let index = completedTrackers.firstIndex(where: {$0.id == actualId}) else { return }
            
            // Добавляем новые даты к уже существующему треку
            addDateInTrackerArray(actualDate: actualDate, actualId: actualId, indexElement: index)
            
            // Повышаем каунтер для общей модели
            correctedCategoriesCounter(section: section, item: item, action: ActionWithArray.add)
            
            print("Текущий массив после добавления еще одной датой ", completedTrackers)
        }
        
        // Если id нету добавляем
        else {
            completedTrackers.append(TrackerRecord(id: actualId, trackCompletionDate: [actualDate]))
            // MARK: ДОБАВИТЬ correctedCategoriesCounter СЮДА
            correctedCategoriesCounter(section: section, item: item, action: ActionWithArray.add)
            print("Добавлен новый элемент в массив", completedTrackers)
            print("Это категориес после добавления нового элемента на дургой день недели обратить внимание на count - \(categories)")
        }
    }
    
    // Метод +/- каунтер в завиисимсоти от выбранного action
    private func correctedCategoriesCounter(section: Int, item: Int, action: ActionWithArray){
        // Копируем текущие данные
        let newCategories = categories
        let trackerToUpdate = newCategories[section].trackerArray[item]
        let timeTableToUpdate = trackerToUpdate.timeTable
        
        // Выбираем прибавлять или уменьшать каунтер
        let chooseAction = action == ActionWithArray.add ? timeTableToUpdate.dayCount + 1 : timeTableToUpdate.dayCount - 1
        
        // Создаем новый трек с обновленным значением dayCount
        let newTrack = Tracker(id: trackerToUpdate.id,
                               name: trackerToUpdate.name,
                               color: trackerToUpdate.color,
                               emoji: trackerToUpdate.emoji,
                               timeTable: TimeTabel(dayCount: chooseAction,
                                                    dayOfWeek: trackerToUpdate.timeTable.dayOfWeek))
        
        // Создаем новый массив треков и заменяем старый
        var newTrackers = newCategories[section].trackerArray
        newTrackers[item] = newTrack
        
        // Создаем новую категорию
        let newCategory = TrackerCategory(title: newCategories[section].title, trackerArray: newTrackers)
        
        // Обновляем наш массив с данными
        var actualCategories = categories
        actualCategories[section] = newCategory
        categories = actualCategories
    }
    
    // Метод удаляет существующую дату из рекорда и в случае если это последняя дата удаляет весь рекорд для трека
    private func removeDateInTrackerArray(actualDate: String, actualId: UInt, indexElement: Array<TrackerRecord>.Index){
        
        // Копируем старый массив и удаляем его старую дату
        var actualRemoveDate = completedTrackers[indexElement].trackCompletionDate
        actualRemoveDate.removeAll { $0 == actualDate
        }
        
        // Создаем новый рекорд
        let newRecord = TrackerRecord(id: actualId, trackCompletionDate: actualRemoveDate)
        
        // Обновляем
        var newArrayCompletedTrackers = completedTrackers
        newArrayCompletedTrackers[indexElement] = newRecord
        completedTrackers = newArrayCompletedTrackers
        
        // Проверяем необхтодимость полного удлаения
        if completedTrackers[indexElement].trackCompletionDate.isEmpty {
            completedTrackers.remove(at: indexElement)
        } else {
            print("Текущий массив не пустой, количество элементов - \(completedTrackers.count)")
        }
    }
    
    // Метод добавляет completedTrackers
    private func addDateInTrackerArray(actualDate: String, actualId: UInt, indexElement: Array<TrackerRecord>.Index){
        
        // Копируем старый массив и обновляем его новой датой
        var actualDates = completedTrackers[indexElement].trackCompletionDate
        actualDates.append(actualDate)
        
        // Создаем новый рекорд
        let newRecord = TrackerRecord(id: actualId, trackCompletionDate: actualDates)
        
        // Обновляем
        var newArrayCompletedTrackers = completedTrackers
        newArrayCompletedTrackers[indexElement] = newRecord
        completedTrackers = newArrayCompletedTrackers
    }
}

extension TrackersViewController {
    
    private func add(newView: UIView){
        view.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
    }
}
