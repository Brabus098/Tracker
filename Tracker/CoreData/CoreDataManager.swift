//  CoreDataManager.swift

import CoreData

final class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    
    private let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private override init() {
        // Создаем контейнер
        persistentContainer = NSPersistentContainer(name: "Model")
        
        super.init()
        
        // Загружаем хранилище
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

// Update Counter
extension CoreDataManager {
    
    func updateTimeTableForTrackWithId(id: Int, actualDate: String){
        
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let recordStore = TrackerRecordStore(context: context)
        
        do {
            // Получаем доступ к элементу по id через контекст
            let result = try context.fetch(fetchRequest)
            try result.forEach { tracker in
                
                guard tracker.id == id else { return }
                let completionDate = tracker.records?.completitionDate?.allObjects as? [TrackerCompletionDate] ?? []
                
                // ищем трек с нужным id и проверяем содержит ли он нужную дату, если она уже есть, удаляем.
                if completionDate.contains(where: { $0.date == actualDate
                }) {
                    
                    try recordStore.deleteRecord(for: tracker, with: actualDate)
                    try updateCounter(trackerCoreData: tracker)
                    
                } else {  // если дата не найдена добавляем ее
                    
                    try recordStore.createRecord(for: tracker, with: actualDate) // сохраняем новую дату
                    try updateCounter(trackerCoreData: tracker)
                }
            }
        } catch {
            print("Не удалось добавить новую дату")
        }
    }
    
    // Метод обновляет счетчик выполненных треков в БД
    private func updateCounter(trackerCoreData: TrackerCoreData) throws {
        
        if let countOfSuccessTrack = trackerCoreData.records?.completitionDate?.count {
            trackerCoreData.timeTable?.dayCount = Int32(countOfSuccessTrack)
        }
        
        try context.save()
    }
}
// Update counter button
extension CoreDataManager {
    
    // Метод проверяет вхождение текущей даты в рекорд для изменения состояния кнопки
    func checkContainsDateFor(id: Int16, actualDate: String) -> Bool {
        
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            guard let tracker = try context.fetch(request).first else {
                return false
            }
            
            // Получаем массив дат
            guard let actualRecords = tracker.records?.completitionDate?.allObjects as? [TrackerCompletionDate] else {
                return false
            }
            
            // Проверяем наличие даты
            let containsDate = actualRecords.contains { record in
                return record.date ?? "" == actualDate
            }
            
            var result = containsDate ? true : false
            return result
            
        } catch { return false }
    }
}

// Helpful methods
extension CoreDataManager {
    func printAllTrackers() {
        let request = TrackerCoreData.fetchRequest()
        do {
            let trackers = try context.fetch(request)
            print("\nFound \(trackers.count) trackers:")
            for tracker in trackers {
                
                let weekDays = tracker.timeTable?.weekDays?.allObjects as? [WeekDayCoreData] ?? []
                let dayNames = weekDays.map { $0.order ?? 0}
                
                print("""
                Tracker ID: \(tracker.id)
                Name: \(tracker.name ?? "nil")
                Color: \(tracker.color ?? "nil")
                Emoji: \(tracker.emoji ?? "nil")
                DayCount: \(tracker.timeTable?.dayCount)
                RecordSet: \(String(describing: tracker.records?.completitionDate))
                DayForRep: \(dayNames)
                ----------------------
                """)
            }
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    func printAllEntities() {
        let entities = persistentContainer.managedObjectModel.entities
        for entity in entities {
            print("\nEntity: \(entity.name ?? "unnamed")")
            print("Attributes:")
            for property in entity.properties {
                if let attribute = property as? NSAttributeDescription {
                    print("- \(attribute.name): \(attribute.attributeType.toString())")
                }
            }
            print("Relationships:")
            for property in entity.properties {
                if let relationship = property as? NSRelationshipDescription {
                    print("- \(relationship.name) → \(relationship.destinationEntity?.name ?? "unknown")")
                }
            }
        }
    }
}

extension NSAttributeType {
    func toString() -> String {
        switch self {
        case .integer16AttributeType: return "Int16"
        case .integer32AttributeType: return "Int32"
        case .integer64AttributeType: return "Int64"
        case .decimalAttributeType: return "Decimal"
        case .doubleAttributeType: return "Double"
        case .floatAttributeType: return "Float"
        case .stringAttributeType: return "String"
        case .booleanAttributeType: return "Bool"
        case .dateAttributeType: return "Date"
        case .binaryDataAttributeType: return "Binary"
        case .UUIDAttributeType: return "UUID"
        case .URIAttributeType: return "URI"
        default: return "Unknown"
        }
    }
}
