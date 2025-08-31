//  TrackersViewController.swift

import UIKit

final class TrackersViewController: UIViewController {
    
    weak var track: TrackCollectionProtocol? // ссылка на коллекцию
    
    private let trackerRecordStore = TrackerRecordStore()
    private let storeReader = TrackerStoreReader()
    lazy var trackerWriterStore = TrackerStoreWriter(recordStore: self.trackerRecordStore)
    private lazy var trackerCategoryStore = TrackerCategoryStore(trackerWriter: trackerWriterStore, trackerRider: storeReader)
    
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
    private var completedTrackers = [TrackerRecord]() // массив с выполнеными треками
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBaseView()
        setupImageView()
        setupConstraint()
        setUpNavigationPlusButton()
        setupDatePicker()
        setupCollection(dataBase: categories) // ПЕРЕМЕЩЕНА ИЗ StartView
        actionWhitDatePicker(datePiker)
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
        track.configure(controllerForCollection: self)
        
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
    
    // Метод срабатывает при изменении даты в датапикере
    @objc private func actionWhitDatePicker(_ sender: UIDatePicker){
        
        let calendarCurrent = Calendar.current
        let weekday = calendarCurrent.component(.weekday, from: sender.date)
        let selectedFormattedDate = WeekDays(rawValue: weekday) // определяем номер дня недели
        track?.currentDate = sender.date // задаем выбранную дату чтобы отключить активность кнопок
        let actualCountOfTrackForDay = track?.updateForDay(selectedFormattedDate?.rawValue ?? 0 )
        // определяем день недели для выбранной даты
        
        makeCollectionInvisible(count: actualCountOfTrackForDay ?? 0)
    }
    // Метод коллекции срабатывает если треков на выбранный день нет
    private func makeCollectionInvisible(count: Int){
        if count == 0 {
            track?.collection.layer.opacity = 0
        } else {
            track?.collection.layer.opacity = 1
        }
    }
}

//  MARK: TrackersViewControllerProtocol
extension TrackersViewController: TrackersViewControllerProtocol {
    
    // Метод принимает данные с формы через замыкание
    func updateCategoriesArray(new array: [TrackerCategory]) {
        do {
            try trackerCategoryStore.addNewTrackerCategory(array) // добавляем новый трек в БД
            try CoreDataManager.shared.context.save()
            actionWhitDatePicker(datePiker)
        } catch {
            print("КРИТИЧЕСКАЯ ОШИБКА: \(error)")
        }
    }
}

// MARK: TrackCollectionActionDelegate
extension TrackersViewController: TrackCollectionActionDelegate {
    
    // Метод вызываемый делегирующим объектом(коллекцией) реагирует на изменение состояния кнопки в ячейки
    func didCompleteTracker(_ trackerId: UInt) {
        
        let todayDateArray = datePiker.date.formatted().dataFormatter()
        
        CoreDataManager.shared.updateTimeTableForTrackWithId(id: Int(trackerId), actualDate: todayDateArray)
        
        track?.reloadData()
    }
}

extension TrackersViewController {
    
    private func add(newView: UIView){
        view.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
    }
}
