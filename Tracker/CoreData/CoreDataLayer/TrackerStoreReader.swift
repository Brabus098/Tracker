// TrackerStoreReader.swift

import Foundation
import CoreData

final class TrackerStoreReader: NSObject {
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var frc: NSFetchedResultsController<TrackerCoreData>!
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFRC()
    }
    
    // Метод достает трек из БД для заполнения коллекции
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard let object = frc.object(at: indexPath) as? TrackerCoreData else { return nil }
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
            print("Ошибка FRC: \(error)")
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
        frc.sections?[section].name ?? ""
    }
}

// MARK: Filters methods for tracks
extension TrackerStoreReader {
    
    // Метод помогает фильтровать треки во дням недели
    func updateFilter(for day: Int) -> Int {
        frc.fetchRequest.predicate = NSPredicate(format: "ANY timeTable.weekDays.order == %d", day)
        do {
            try frc.performFetch()
            return frc.fetchedObjects?.count ?? 0
        } catch {
            print("Ошибка обновления фильтра: \(error)")
            return 0
        }
    }
    
    // Метод для обновления fetchedResultsController c учетом фильтра по дням
    func updateFilterForDay(_ day: Int) -> Int{
        // Задаем новый фильтр
        let newPredicate = NSPredicate(format: "ANY timeTable.weekDays.order == %d", day)
        frc.fetchRequest.predicate = newPredicate
        
        do {
            try frc.performFetch()
            return frc.fetchedObjects?.count ?? 0
        } catch {
            print("Ошибка обновления фильтра: \(error)")
        }
        return 0
    }
}

extension TrackerStoreReader {
    
    // метод выгружает из БД все треки
    func loadTrackers() -> [TrackerCategory] {
        var categoryArray = [TrackerCategory]()
        
        do {
            try frc.performFetch()
            guard let fetchedObjects = frc.fetchedObjects else {
                print("Не удалось получить объекты из fetchedResultsController")
                return categoryArray
            }
            
            var categoriesDict = [String: [Tracker]]()
            
            for trackerCoreData in fetchedObjects {
                guard let categoryTitle = trackerCoreData.category?.title else {
                    print("Трекер без категории: \(trackerCoreData.name ?? "no name")")
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
            
        } catch {
            print("Ошибка при загрузке трекеров: \(error)")
        }
        return categoryArray
    }
    
    // метод возвращает расписание для трека
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
