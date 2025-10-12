// TrackerStoreReader.swift

import Foundation
import CoreData

final class TrackerStoreReader: NSObject {
    
    enum FilterState {
        case didTracks
        case unDidTracks
    }
    
    weak var delegate: TrackerStoreDelegate?
    weak var filterDelegate: FilterDelegate?
    
    private let context: NSManagedObjectContext
    private var frc: NSFetchedResultsController<TrackerCoreData>!
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFRC()
    }
    
    // Метод достает трек из БД для заполнения коллекции
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let object = frc.object(at: indexPath)
        return Tracker(
            id: UInt(object.id),
            name: object.name ?? "",
            color: object.color ?? "",
            emoji: object.emoji ?? "",
            timeTable: convertTimeTable(CoreDatatype: object.timeTable ?? TimeTableCoreData())
        )
    }
    
    // Метод проверяет вхождение даты в рекорд
    func checkContainsDate(id: Int16, date: String) -> Bool {
        CoreDataManager.shared.checkContainsDateFor(id: id, actualDate: date)
    }
    
    // Метод выгружает из БД все треки
    func loadTrackers() -> [TrackerCategory] {
        var categoryArray = [TrackerCategory]()
        
        do {
            try frc.performFetch()
            guard let fetchedObjects = frc.fetchedObjects else {
                print("[TrackerStoreReader]: Не удалось получить объекты из fetchedResultsController")
                return categoryArray
            }
            
            var categoriesDict = [String: [Tracker]]()
            
            for trackerCoreData in fetchedObjects {
                guard let categoryTitle = trackerCoreData.category?.title else {
                    print("[TrackerStoreReader]: Трекер без категории: \(trackerCoreData.name ?? "no name")")
                    continue
                }
                
                let tracker = Tracker(
                    id: UInt(trackerCoreData.id),
                    name: trackerCoreData.name ?? "",
                    color: trackerCoreData.color ?? "",
                    emoji: trackerCoreData.emoji ?? "",
                    timeTable: convertTimeTable(CoreDatatype: trackerCoreData.timeTable ?? TimeTableCoreData())
                )
                
                if categoriesDict[categoryTitle] == nil {
                    categoriesDict[categoryTitle] = []
                }
                categoriesDict[categoryTitle]?.append(tracker)
            }
            
            for (title, trackers) in categoriesDict {
                categoryArray.append(TrackerCategory(title: title, trackerArray: trackers))
            }
            
        } catch { print("[TrackerStoreReader]: Ошибка при загрузке трекеров: \(error)") }
        return categoryArray
    }
    
    // Метод возвращает расписание для трека
    func convertTimeTable(CoreDatatype: TimeTableCoreData) -> TimeTabel{
        let count = CoreDatatype.dayCount
        var dayArray = [WeekDay]()
        if let weekDayArray = CoreDatatype.weekDays?.allObjects as? [WeekDayCoreData]{
            for day in weekDayArray{
                if let day = day.dayName, let weekDay = WeekDay(rawValue: day) {
                    dayArray.append(weekDay)
                }
            }
        }
        return TimeTabel(dayCount: Int(count), dayOfWeek: dayArray)
    }
}

extension TrackerStoreReader: NSFetchedResultsControllerDelegate {
    
    private func setupFRC() {
        
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        request.relationshipKeyPathsForPrefetching = ["category", "timeTable"]
        
        frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            print("[TrackerStoreReader]: Ошибка FRC: \(error)")
        }
    }
    
    // Метод оповещает коллекцию об обновлении
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateData()
    }
}

// MARK: update collection
extension TrackerStoreReader: TrackerReaderProtocol{
    
    func numberOfSections() -> Int {
        frc.sections?.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        frc.sections?[section].numberOfObjects ?? 0
    }
    
    func titleForSection(_ section: Int) -> String {
        
        guard let sectionInfo = frc.sections?[section] else { return "" }
        let sectionKey = sectionInfo.name  // Например, "0_Закрепленные" или "1_Работа"
        
        // Разделяем по "_" и берём последнюю часть (реальное название)
        let components = sectionKey.components(separatedBy: "_")
        let realTitle = components.last ?? ""
        
        return realTitle
    }
}

// MARK: Filters methods for tracks
extension TrackerStoreReader {
    
    // Метод для обновления fetchedResultsController c учетом фильтра по дням
    func updateFilterForDay(_ day: Int) -> Int {
        let newPredicate = NSPredicate(format: "ANY timeTable.weekDays.order == %d", day)
        frc.fetchRequest.predicate = newPredicate
        delegate?.didUpdateData()
        
        do {
            try frc.performFetch()
            return frc.fetchedObjects?.count ?? 0
        } catch {
            print("[TrackerStoreReader]: Ошибка обновления фильтра по дням: \(error)")
        }
        return 0
    }
    
    func findText(element: String) -> Int? {
        
        let tackers = loadTrackers()
        var newArray = [Tracker]()
        
        for i in tackers { newArray += i.trackerArray }
        
        for i in newArray {
            
            if let first = i.name.first, first == element.first {
                finFilter(trackName: String(first))
            }
            if i.name == element { return finFilter(trackName: i.name) }
        }
        return nil
    }
    
    private func finFilter(trackName: String) -> Int{
        
        let newPredicate = NSPredicate(format: "name CONTAINS[cd] %@", trackName)
        frc.fetchRequest.predicate = newPredicate
        
        do {
            try frc.performFetch()
            DispatchQueue.main.async {
                self.delegate?.didUpdateData()
            }
            
            return frc.fetchedObjects?.count ?? 0
        } catch {
            print("[TrackerStoreReader]: Ошибка обновления фильтра: \(error)")
        }
        return 0
    }
    
    func filter(to state: FilterState, day: Int, date: String) -> Int {
        
        switch state {
            
        case .didTracks:
            let datePredicate = NSPredicate(format: "ANY records.completitionDate.date == %@", date)
            let dayPredicate = NSPredicate(format: "ANY timeTable.weekDays.order == %d", day)
            
            frc.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, dayPredicate])
        case .unDidTracks:
            let predicate = NSPredicate(
                format: "ANY timeTable.weekDays.order == %d AND SUBQUERY(records, $r, ANY $r.completitionDate.date == %@).@count == 0",
                day,
                date
            )
            frc.fetchRequest.predicate = predicate
        }
        
        do {
            try frc.performFetch()
            
            DispatchQueue.main.async {
                self.delegate?.didUpdateData()
            }
            return frc.fetchedObjects?.count ?? 0
        } catch {
            print("[TrackerStoreReader]: Ошибка обновления фильтра: \(error)")
        }
        return 0
    }
}
// MARK: methods for statistic
extension TrackerStoreReader {
    // Метод возращает все даты выполненых треков
    func loadDate() -> [String] {
        var stringArrayToReturn = [String]()
        
        do {
            try frc.performFetch()
            guard let fetchedObjects = frc.fetchedObjects else { return [""] }
            
            for trackerDate in fetchedObjects {
                if let dateArray = trackerDate.records?.completitionDate as? NSSet {
                    let completionDates = dateArray.allObjects.compactMap { $0 as? TrackerCompletionDate }
                    let dates = completionDates.compactMap { $0.date }
                    stringArrayToReturn += dates
                }
            }
        } catch {
            print("[TrackerStoreReader]: Не удалось получить объекты из fetchedResultsController")
        }
        return stringArrayToReturn
    }
    
    // Метод возвращает словарь с необходимым количеством треков для каждого из дней недели
    func loadCountTrackForDayOfWeek() -> [WeekDay:Int] {
        var dict = [WeekDay:Int]()
        
        do {
            try frc.performFetch()
            guard let object = frc.fetchedObjects else { return dict }
            
            for track in object {
                let array = track.timeTable?.weekDays?.allObjects as? [WeekDayCoreData]
                if let dayArray = array {
                    for i in dayArray {
                        if let day = i.dayName, let weekDay = WeekDay(rawValue: day) {
                            dict[weekDay ,default: 0] += 1
                        }
                    }
                }
            }
        } catch {
            print("[TrackerStoreReader]: Не удалось получить объекты из fetchedResultsController")
        }
        return dict
    }
}
