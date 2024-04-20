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
        
         // НАСТРОЙКА МИГРАЦИИ
         let description = persistentContainer.persistentStoreDescriptions.first
         description?.shouldMigrateStoreAutomatically = true
         description?.shouldInferMappingModelAutomatically = true
        
        // Загружаем хранилище
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("[CoreDataManager]: Ошибка миграции: \(error)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func removeTrack(with title: String) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate =  NSPredicate(format: "name == %@" , title)
        
        if let result = try context.fetch(fetchRequest).first {
            context.delete(result)
            try context.save()
        }
    }
}

extension CoreDataManager{
    func editOptionsFor(trackWithGoalTitle: String,
                        newTimeTable: [WeekDay]?,
                        newCategoryTitle: String?,
                        newEmoji: String?,
                        newTrackName: String?,
                        newColor: String? ) throws {
        // Метод меняет эмоджи
        if let newEmoji { try? editEmoji(with: trackWithGoalTitle, newEmoji: newEmoji) }
        // Метод цвет трека
        if let newColor { try? editColor(with: trackWithGoalTitle, newColor: newColor) }
        // Метод меняет категорию
        if let newCategoryTitle { try? editCategoryTitle(title: trackWithGoalTitle, newCategoryTitle: newCategoryTitle) }
        // Метод меняет расписание
        if let newTimeTable { try? editTimeTable(title: trackWithGoalTitle, newTimeTable: newTimeTable) }
        // Метод меняет название трека
        if let newTrackName { try? editTrackGoalName(with: trackWithGoalTitle, newName: newTrackName) }
    }
    
    // Метод меняет название трека
    private func editTrackGoalName(with title: String, newName: String) throws {
        try context.performAndWait {
            
            let results = try actualRequestWithPredicate(track: title)
            
            if let trackToUpdate = results.first {
                trackToUpdate.name = newName
                try context.save()
            } else {
                print("[CoreDataManager]: Трек с названием '\(title)' не найден")
            }
        }
    }
    
    private func editColor(with title: String, newColor: String) throws {
        try context.performAndWait {
            
            let results = try actualRequestWithPredicate(track: title)
            
            if let trackToUpdate = results.first {
                trackToUpdate.color = newColor
                try context.save()
            } else {
                print("[CoreDataManager]: Трек с названием '\(title)' не найден")
            }
        }
    }
    
    private func editEmoji(with title: String, newEmoji: String) throws {
        try context.performAndWait {
            
            let results = try actualRequestWithPredicate(track: title)
            
            if let trackToUpdate = results.first {
                trackToUpdate.emoji = newEmoji
                try context.save()
            } else {
                print("[CoreDataManager]: Трек с названием '\(title)' не найден")
            }
        }
    }
    
    func changeCategoryTitle(status: Bool, trackName: String, fixTitle: String) throws {
        
        try context.performAndWait {
            let results = try actualRequestWithPredicate(track: trackName)
            
            if let trackToUpdate = results.first,
               let category = trackToUpdate.category { // Проверяем что категория существует
                
                if status {
                    category.fixCategory = true
                   category.oldTitle = category.title
                    category.title = fixTitle
                    try context.save()
                    // меняем состояние
                } else {
                     category.fixCategory = false
                    category.title = category.oldTitle // старое значение переходит в основное
                    category.oldTitle = nil
                    try context.save()
                }
                NotificationCenter.default.post(name: Notification.Name("categoryNameDidUpdate"), object: nil)
            } else {
                print("[CoreDataManager]: Трек или категория не найдены")
            }
        }
    }
    
    private func editCategoryTitle(title: String, newCategoryTitle: String) throws {
        try context.performAndWait {
            let results = try actualRequestWithPredicate(track: title)
            
            if let trackToUpdate = results.first,
               let category = trackToUpdate.category { // Проверяем что категория существует
                    category.title = newCategoryTitle
                    try context.save()
                NotificationCenter.default.post(name: Notification.Name("categoryNameDidUpdate"), object: nil)
            } else {
                print("[CoreDataManager]: Трек или категория не найдены")
            }
        }
    }
    
    private func editTimeTable(title: String, newTimeTable: [WeekDay]) throws {
        try context.performAndWait {
            let results = try actualRequestWithPredicate(track: title)

            if let track = results.first {
                // Удаляем старое расписание
                if let oldTimeTable = track.timeTable {
                    context.delete(oldTimeTable)
                }

                // Создаем новое расписание
                let newTimeTableEntity = TimeTableCoreData(context: context)
                
                for day in newTimeTable {
                    let weekDay = WeekDayCoreData(context: context)
                    weekDay.dayName = day.rawValue
                    weekDay.order = Int16(day.toWeekDays()?.rawValue ?? 0)
                    newTimeTableEntity.addToWeekDays(weekDay)
                }
                track.timeTable = newTimeTableEntity
                try context.save()
            }
        }
    }
    
    private func actualRequestWithPredicate(track name: String) throws -> [TrackerCoreData] {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        let results = try context.fetch(fetchRequest)
        
        return results
    }
}

// Update Counter
extension CoreDataManager {
    
    // Метод меняет Расписание
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
            print("[CoreDataManager]: Не удалось добавить новую дату")
        }
    }
    
    // Метод обновляет счетчик выполненных треков в БД
    private func updateCounter(trackerCoreData: TrackerCoreData) throws {
        
        if let countOfSuccessTrack = trackerCoreData.records?.completitionDate?.count {
            trackerCoreData.timeTable?.dayCount = Int32(countOfSuccessTrack) }
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
            guard let tracker = try context.fetch(request).first else { return false }

            // Получаем массив дат
            guard let actualRecords = tracker.records?.completitionDate?.allObjects as? [TrackerCompletionDate] else { return false }
            // Проверяем наличие даты
            let containsDate = actualRecords.contains { record in
                return record.date ?? "" == actualDate
            }
            
            let result = containsDate ? true : false
            return result
        } catch { return false }
    }
}

// MARK: Load methods for Edit controller
extension CoreDataManager {
    func backActualRecord(title: String) throws -> String {
        try context.performAndWait {
            let results = try actualRequestWithPredicate(track: title)
            
            if let track = results.first {
                return String(track.records?.completitionDate?.count ?? 0)
            }
            return ""
        }
    }
    
    func backActualTrackGoal(title: String) throws -> String {
        try context.performAndWait {
        
            let result = try actualRequestWithPredicate(track: title)
            
            if let track = result.first {
                return String(track.name ?? "")
            }
            return ""
        }
    }
    
    func backActualEmoji(title: String) throws -> String {
        try context.performAndWait {
            let result = try actualRequestWithPredicate(track: title)
            
            if let track = result.first {
                return String(track.emoji ?? "")
            }
            return ""
        }
    }
    
    func backActualColor(title: String) throws -> String {
        try context.performAndWait {
            let result = try actualRequestWithPredicate(track: title)
            
            if let track = result.first {
                return String(track.color ?? "")
            }
            return ""
        }
    }
    
    func loadTitleOfCategory(title: String) throws -> String {
        try context.performAndWait {
            let result = try actualRequestWithPredicate(track: title)
            
            if let track = result.first {
                
                print("Это тот самый тайтл", String(track.category?.title ?? ""))
                return String(track.category?.title ?? "")
            }
            return ""
        }
    }
    
    func loadDayForRepeat(title: String) throws -> [String] {
        try context.performAndWait {
            let result = try actualRequestWithPredicate(track: title)
            
            if let track = result.first {
                let weekDays = track.timeTable?.weekDays?.allObjects as? [WeekDayCoreData] ?? []
                let dayNames = weekDays.map { $0.dayName ?? ""}
                print(dayNames)
                return dayNames
            }
            return [""]
        }
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
                StatusTrack: \(tracker.isRegular)
                Date: \(tracker.creationDate)
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
    
    func printAllRecords() {
        let request = TrackerRecordCoreData.fetchRequest()
        
        // Предзагружаем все связанные данные
        request.relationshipKeyPathsForPrefetching = ["tracker", "completitionDate"]
        request.returnsObjectsAsFaults = false
        
        do {
            let records = try context.fetch(request)
            print("\n=== TRACKERS WITH COMPLETION DATES ===")
            print("Total records found: \(records.count)")
            
            for record in records {
                // Принудительно загружаем данные
                context.refresh(record, mergeChanges: true)
                
                // Получаем название трекера
                let trackerName = record.tracker?.name ?? "Unknown Tracker"
                let trackerID = record.tracker?.id ?? 0
                
                // Получаем даты выполнения (как строки)
                var completionDates: [String] = []
                
                if let completionDatesSet = record.completitionDate as? NSSet {
                    for case let dateEntity as TrackerCompletionDate in completionDatesSet {
                        context.refresh(dateEntity, mergeChanges: true)
                        
                        // dateEntity.date это String, а не Date!
                        if let dateString = dateEntity.date as? String {
                            completionDates.append(dateString)
                        } else if let date = dateEntity.date {
                            // Если это не String, выводим как есть
                            completionDates.append("\(date)")
                        }
                    }
                }
                
                print("""
                📊 Tracker: \(trackerName) (ID: \(trackerID))
                Date: \(record.tracker?.creationDate)
                Status: \(record.tracker?.isRegular)
                📅 Completion Dates: \(completionDates)
                🔢 Total Completions: \(completionDates.count)
                ---
                """)
            }
            
        } catch {
            print("Failed to fetch records: \(error)")
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
