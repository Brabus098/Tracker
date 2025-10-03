//  TrackersViewController.swift

import UIKit
import AppMetricaCore
final class TrackersViewController: UIViewController {
    
    weak var track: TrackCollectionProtocol? // ссылка на коллекцию
    
    // CoreData
    private let trackerRecordStore = TrackerRecordStore()
    private let storeReader = TrackerStoreReader()
    private lazy var trackerWriterStore = TrackerStoreWriter(recordStore: self.trackerRecordStore)
    private lazy var trackerCategoryStore = TrackerCategoryStore(trackerWriter: trackerWriterStore, trackerRider: storeReader)
    private var viewModel: TrackViewModel
    private var filterUserDefaults: FiltersProtocol
    
    // Menu + Blur
    private var blurView: BlurView?
    private var selectedCell: UITableViewCell?
    private var menuView: MenuView?
    
    private lazy var filterButton = {
        let button = UIButton()
        self.add(newView: button)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.setTitle("Фильтры", for: .normal)
        
        button.backgroundColor = UIColor.filterButton
        button.addAction(UIAction {[weak self]_ in
            let controller = TrackFilterController()
            controller.actionWithFilterDelegate = self
            controller.filterDelegate = self?.filterUserDefaults
            let navigation = UINavigationController(rootViewController: controller)
            
            self?.sendMetrics(mainAction: "click_filterButton", metricsAction: .addTrack)
            self?.present(navigation, animated: true)
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var searchBar = {
        let searchBar = UISearchBar()
        add(newView: searchBar)
        
        searchBar.placeholder = String(localized: "Search")
        searchBar.removeSystemPadding()
        searchBar.searchTextField.font = UIFont(name: "SFPro-Regular", size: 17)
        searchBar.barTintColor = .searchBar
        searchBar.layer.borderWidth = 0
        searchBar.layer.masksToBounds = true
        
        return searchBar
    }()
    
    private lazy var questionLabel = {
        let label = UILabel()
        add(newView: label)
        
        label.text = NSLocalizedString("What are we going to track?", comment: "")
        label.textAlignment = .center
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        
        return label
    }()
    
    private lazy var mainTrackLabel = {
        let label = UILabel()
        label.text = String(localized: "Trackers")
        label.textColor = .colorMainTrackLabel
        label.textAlignment = .left
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        add(newView: label)
        
        return label
    }()
    
    private lazy var labelForDataPiker = {
        let label = UILabel()
        label.text = datePiker.date.formatted().dataFormatter()
        label.textColor = .black
        label.font =  UIFont(name: "SFPro-Regular", size: 17)
        
        return label
    }()
    
    private let noTrackImageView = UIImageView()
    private let datePiker = UIDatePicker()
    private var currentDate: Date = Date()
    private let colors = Colors()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        openController()
        clearUserDefaults()
        setupBaseView()
        setupImageView()
        setupConstraint()
        setUpNavigationPlusButton()
        setupDatePicker()
        setupCollection()
        actionWhitDatePicker(datePiker)
        setupLongPressGesture()
        setupTapGesture()
        setupConstraintForFilterButton()
    }
    
    init(track: TrackCollectionProtocol, viewModel: TrackViewModel, filterUserDefaults: FiltersProtocol) {
        self.track = track
        self.viewModel = viewModel
        self.filterUserDefaults = filterUserDefaults
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        sendMetrics(mainAction: "CloseController", metricsAction: .close)
    }
    
    func bind(){
        viewModel.searchStatus = { [weak self] status in
            self?.changeStateCollection(status: status)
        }
    }
    
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "filter")
        UserDefaults.standard.synchronize()
    }
    
    enum MetricsAction: String {
        case open = "open"
        case close = "close"
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
    }
    
    private func sendMetrics(mainAction: String, metricsAction: MetricsAction) {
        var parameters = [String: String]()
        parameters["event:"] = mainAction
        parameters["screen:"] = "Main"
        
        switch metricsAction {
        case .open, .close:
            return
        case .addTrack:
            parameters["items"] = "add_track"
        case .track:
            parameters["items"] = "track"
        case .filter:
            parameters["items"] = "filter"
        case .edit:
            parameters["items"] = "edit"
        case .delete:
            parameters["items"] = "delete"
        }
        
        AppMetrica.reportEvent(name: metricsAction.rawValue,
                               parameters: parameters,
                               onFailure: { error in
            print("[TrackersViewController]: REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    private func openController(){
        sendMetrics(mainAction: "Open_Controler", metricsAction: .open)
    }
    
    // MARK: Setup Views
    private func setupCollection(){
        guard let track else { return }
        track.configure(controllerForCollection: self)
        
        add(newView: track.collection)
        
        track.collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0) // MARK: при лагах коллекции смотреть сюда
        
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
        datePiker.layer.cornerRadius = 16
        datePiker.locale = Locale(identifier: "ru_RU")
        
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
    
    private func addToNavBar(piker: UIDatePicker) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let container = UIView()
        container.backgroundColor = .dataPikerBack
        container.layer.cornerRadius = 8
        
        navigationBar.addSubview(container)
        navigationBar.addSubview(labelForDataPiker)
        navigationBar.addSubview(piker)
        
        labelForDataPiker.layer.zPosition = 1000
        container.layer.zPosition = 1
        piker.layer.zPosition = 0
        
        piker.alpha = 0.011
        piker.isUserInteractionEnabled = true
        
        labelForDataPiker.translatesAutoresizingMaskIntoConstraints = false
        piker.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
            container.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 34),
            container.widthAnchor.constraint(equalToConstant: 87),
            piker.heightAnchor.constraint(equalToConstant: 34),
            piker.widthAnchor.constraint(equalToConstant: 87),
            
            piker.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
            piker.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            
            labelForDataPiker.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labelForDataPiker.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
    }
    
    private func setupBaseView(){
        bind()
        view.backgroundColor = .mainViewBack
        track?.collection.backgroundColor = .mainViewBack
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(forName: Notification.Name("categoryNameDidUpdate"), object: nil, queue: nil, using: {[weak self] _ in
            let selectedFormattedDate = WeekDays(rawValue: self?.giveDayNow() ?? 0) // определяем номер дня недели
            self?.track?.updateForDay(selectedFormattedDate?.rawValue ?? 0 )
        })
    }
    
    private func setupImageView() {
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
        sendMetrics(mainAction: "AddTrack", metricsAction: .addTrack)
        let createTrackController = ChooseTrackController()
        createTrackController.parentTrackerVC = self
        
        let trackNavigation = UINavigationController(rootViewController: createTrackController)
        DispatchQueue.main.async {
            self.present(trackNavigation, animated: true)
        }
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
            searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0),
        ])
    }
    
    private func setupConstraintForFilterButton(){
        NSLayoutConstraint.activate([
            // FilterButton
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -140),
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 140),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: Methods with movement logic
extension TrackersViewController {
    
    // Метод срабатывает при изменении даты в датапикере
    @objc private func actionWhitDatePicker(_ sender: UIDatePicker){
        
        labelForDataPiker.text = sender.date.toShortFormat()
        
        let calendarCurrent = Calendar.current
        let weekday = calendarCurrent.component(.weekday, from: sender.date)
        let selectedFormattedDate = WeekDays(rawValue: weekday) // определяем номер дня недели
        track?.currentDate = sender.date // задаем выбранную дату чтобы отключить активность кнопок
        
        let actualCountOfTrackForDay = track?.updateForDay(selectedFormattedDate?.rawValue ?? 0 )
        makeCollectionInvisible(count: actualCountOfTrackForDay ?? 0)
        // определяем день недели для выбранной даты
        filterDidUpdate()
        
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
            print("[TrackersViewController]: Ошибка при добавлении в БД \(error)")
        }
    }
}

// MARK: TrackCollectionActionDelegate
extension TrackersViewController: TrackCollectionActionDelegate {
    
    // Метод вызываемый делегирующим объектом(коллекцией) реагирует на изменение состояния кнопки в ячейки
    func didCompleteTracker(_ trackerId: UInt) {
        sendMetrics(mainAction: "TapOnTrack", metricsAction: .track)
        let todayDateArray = datePiker.date.formatted().dataFormatter()
        CoreDataManager.shared.updateTimeTableForTrackWithId(id: Int(trackerId), actualDate: todayDateArray)
        track?.reloadDataInCollection()
    }
    
    func changeStateCollection(status: Bool) {
        
        if status {
            track?.collection.isHidden = false
            changeImage(status: false)
        } else {
            track?.collection.isHidden = true
            changeImage(status: true)
        }
    }
    
    // Метод action delegate
    func showNotFoundImage(status: Bool) {
        
        if status {
            //makeCollectionInvisible(count: 0)
            changeImage(status: true)
        } else {
            //makeCollectionInvisible(count: 1)
            changeImage(status: false)
        }
    }
    
    private func changeImage(status: Bool) {
        
        if status {
            noTrackImageView.image = UIImage(named: "emojiMonocol")
            noTrackImageView.layer.zPosition = 10
            questionLabel.text = "Ничего не найдено"
            questionLabel.layer.zPosition = 10
        } else {
            noTrackImageView.image = UIImage(named: "noTrackImageLogo")
            questionLabel.text = "Что будем отслеживать?"
        }
    }
    
    // Метод коллекции срабатывает если треков на выбранный день нет
    private func makeCollectionInvisible(count: Int){
        
        if count == 0 {
            track?.collection.layer.opacity = 0
            changeImage(status: false)
            filterButton.isHidden = true
        } else {
            track?.collection.layer.opacity = 1
            filterButton.isHidden = false
        }
    }
}

extension TrackersViewController {
    
    func setupLongPressGesture(){
        guard let track else { return }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(onBlur(_:)))
        longPressGesture.minimumPressDuration = 0.5
        
        track.collection.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func onBlur(_ tap: UILongPressGestureRecognizer) {
        guard let track else { return }
        
        let location = tap.location(in: track.collection)
        switch tap.state {
            
        case .began:
            guard let indexPath = track.collection.indexPathForItem(at: location), let cell = track.collection.cellForItem(at: indexPath),  let specialCell = track.collection.cellForItem(at: indexPath) as? CollectionViewCell else { return }
            
            addBlurEffect(for: cell, specialCell: specialCell)
            
            // 1. Получаем секцию ячейки
            let section = indexPath.section
            // 2. Получаем заголовок для секции
            if let headerView = track.collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                                                   at: IndexPath(item: 0, section: section)) as? HeaderViewForCell,
               let text = headerView.headerTitleLabel.text {
                setupCustomMenu(for: cell, categoryTitle: text)
            } else {
                print("[TrackersViewController] не удалось создать меню из-за того что у трека нету категории")
            }
        default: break
        }
    }
    
    private func addBlurEffect(for cell: UICollectionViewCell, specialCell: CollectionViewCell) {
        
        let newBlur = BlurView(frame: view.bounds)
        
        // Жест на закрытие в свободной зоне
        let tapOutside = UITapGestureRecognizer.init(target: self, action: #selector(tapOutside(_:)))
        newBlur.addGestureRecognizer(tapOutside)
        
        //получаем координаты ячейки
        let locationItem = cell.convert(cell.bounds, to: view)
        
        // Выбираем только центральную часть ячейки (80% ширины, 90% высоты)
        let targetRect = CGRect(
            x: locationItem.minX,
            y: locationItem.minY,
            width: locationItem.width ,
            height: locationItem.height * 0.60
        )
        
        newBlur.holeRect = targetRect
        add(newView: newBlur)
        
        UIView.animate(withDuration: 0.5) {
            self.blurView?.alpha = 1
        }
        
        blurView = newBlur
    }
    
    @objc private func tapOutside(_ tap: UITapGestureRecognizer){
        let touchOutside = tap.location(in: menuView)
        if menuView?.bounds.contains(touchOutside) == false {
            deleteBlur()
        }
    }
    
    private func setupCustomMenu(for cell: UICollectionViewCell, categoryTitle: String){
        
        guard let custom = cell as? CollectionViewCell,
              let collectionView = cell.superview as? UICollectionView,
              let indexPath = collectionView.indexPath(for: cell) else { return }
        
        var textButtonArray = [String]()
        
        if categoryTitle != "Закрепленные" {
            textButtonArray = [ String(localized: "Pin"), String(localized:"Edit"), String(localized:"Delete") ]
            
        } else {
            textButtonArray = [ String(localized: "Unpin"), String(localized:"Edit"), String(localized:"Delete")]
        }
        
        let menu = MenuView(tableDataBaseActions: textButtonArray,
                            delegate: self,
                            chooseCategoryTitle: custom.getActuaLabel())
        
        let locationItem = cell.convert(cell.bounds, to: view)
        let width: CGFloat = 250
        let height: CGFloat = 48 * 3
        
        // Для корректного отображения меню редактирования: четные индексы - левые, нечетные - правые
        let isRightCell = indexPath.item % 2 == 1
        
        let menuX = isRightCell ? locationItem.maxX - width : locationItem.minX
        let menuY = locationItem.maxY - 50
        
        menu.frame = CGRect(x: menuX, y: menuY, width: width, height: height)
        menu.translatesAutoresizingMaskIntoConstraints = true
        
        if let blurView = blurView {
            view.insertSubview(menu, aboveSubview: blurView)
        } else {
            view.addSubview(menu)
        }
        menuView = menu
    }
    
    func deleteBlur(){
        UIView.animate(withDuration: 0.5, animations: {
            // Убираем видимость
            self.menuView?.alpha = 0
            self.blurView?.alpha = 0 }) { _ in
                
                // Удаляем с вью
                self.menuView?.removeFromSuperview()
                self.blurView?.removeFromSuperview()
                
                // Обниляем чтобы небыло доступа
                self.menuView = nil
                self.blurView = nil
            }
    }
}

extension TrackersViewController {
    func setupTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionForTap(_:)))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    private func add(newView: UIView){
        view.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func giveDayNow() -> Int {
        let calendarCurrent = Calendar.current
        let weekday = calendarCurrent.component(.weekday, from: datePiker.date)
        let selectedFormattedDate = WeekDays(rawValue: weekday)
        return selectedFormattedDate?.rawValue ?? 0
    }
    
    @objc func actionForTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: view) // место нажатия
        guard let collectionTrack = track?.collection else { return }
        
        let collectionFrame = collectionTrack.convert(collectionTrack.bounds, to: view)
        if collectionFrame.contains(tapLocation), searchBar.isFirstResponder  {
            searchBar.resignFirstResponder()
            if searchBar.text?.isEmpty == true {
                track?.collection.isHidden = false
                changeImage(status: false)
                track?.changeFilter(day: giveDayNow())
            }
        }
    }
}

extension TrackersViewController: CustomMenuDelegate {
    
    func choose(action isWas: MenuActions, chooseTitle: String) {
        
        deleteBlur()
        switch isWas{
            
        case .delete:
            sendMetrics(mainAction: "deleteTracks", metricsAction: .delete)
            let action = UIAlertAction(title: "Удалить", style: .destructive, handler: {_ in
                try? CoreDataManager.shared.removeTrack(with: chooseTitle)
            })
            let secondActon = UIAlertAction(title: "Отменить", style: .cancel)
            let alert = UIAlertController(title: "Уверены что хотите удалить трекер?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(action)
            alert.addAction(secondActon)
            present(alert, animated: true)
            
        case .edit:
            sendMetrics(mainAction: "EditTrack", metricsAction: .edit)
            let emoji = EmojiCollection()
            let color = ColorCollection()
            let model = RegularTrackModel()
            let trackViewModel = TrackViewModel(for: model)
            
            let editTrackController = EditTrackController(emojiCollection: emoji, colorCollection: color, titleTrackForSearch: chooseTitle)
            editTrackController.initialize(viewModel: trackViewModel)
            
            let secondTrackNavigation = UINavigationController(rootViewController: editTrackController)
            self.present(secondTrackNavigation, animated: true)  // открываем экран -> запрос к БД на изменение (CoreDataManager.shared.editOptions())
            
        case .fix:
            viewModel.fixStateFor(trackTitle: chooseTitle, state: .fix) // запрос к БД на закрепление
            
        case .unFix :
            viewModel.fixStateFor(trackTitle: chooseTitle, state: .unFix) // снимает закрепление трека
        }
    }
}

extension TrackersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty == true {
            track?.collection.isHidden = false
            changeImage(status: false)
            track?.changeFilter(day: giveDayNow())
        } else {
            track?.findText(title: searchText, store: storeReader)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        track?.collection.isHidden = false
        changeImage(status: false)
        track?.changeFilter(day: giveDayNow())
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // закрытие клавиатуры
        if searchBar.searchTextField.text?.isEmpty == true {
            track?.collection.isHidden = false
        }
    }
}


extension TrackersViewController: ActionFilterDelegate {
    func filterDidUpdate() {
        let filterStatus = filterUserDefaults.chooseFilter
        let todayDate = datePiker.date.formatted().dataFormatter()
        
        switch filterStatus {
        case .allTracks:
            DispatchQueue.main.async { [weak self] in
                self?.noTrackImageView.layer.zPosition = 0
                self?.questionLabel.layer.zPosition = 0
                self?.track?.changeFilter(day: self?.giveDayNow() ?? 0)
                self?.filterButton.titleLabel?.textColor = .white
            }
        case .trackForActualDate:
            
            DispatchQueue.main.async { [weak self] in
                self?.noTrackImageView.layer.zPosition = 0
                self?.questionLabel.layer.zPosition = 0
                self?.filterButton.titleLabel?.textColor = .white
                self?.datePiker.setDate(Date(), animated: true)
                self?.track?.changeFilter(day: self?.giveDayNow() ?? 0)
            }
            filterUserDefaults.chooseFilter = .allTracks
        case .didTracks:
            DispatchQueue.main.async { [weak self] in
                self?.noTrackImageView.layer.zPosition = 0
                self?.questionLabel.layer.zPosition = 0
                self?.filterButton.titleLabel?.textColor = .red
                self?.track?.filterForDidTracks(day: self?.giveDayNow() ?? 0, date: todayDate)
            }
            
        case .unDidTracks:
            DispatchQueue.main.async { [weak self] in
                self?.noTrackImageView.layer.zPosition = 0
                self?.questionLabel.layer.zPosition = 0
                self?.filterButton.titleLabel?.textColor = .red
                self?.track?.filteForUndidTrack(day: self?.giveDayNow() ?? 0, date: todayDate)
            }
        }
    }
}
