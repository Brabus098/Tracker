//  TrackerRecordStore.swift
import CoreData

final class TrackerRecordStore: TrackerRecordStoreProtocol { // класс отвечает за доступ к TrackerRecord
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func createRecord(for tracker: TrackerCoreData, with completionDate: String) throws {
        try context.performAndWait {
            // 1. Получаем или создаем запись трекера
            let record: TrackerRecordCoreData
            
            if let existingRecord = tracker.records {
                record = existingRecord
            } else {
                record = TrackerRecordCoreData(context: context)
                record.tracker = tracker
                tracker.records = record
            }
            
            // 2. Создаем новую дату выполнения
            let newCompletion = TrackerCompletionDate(context: context)
            newCompletion.date = completionDate
            newCompletion.record = record
            
            // 3. Сохраняем контекст
            try context.save()
        }
    }
    
    func deleteRecord(for tracker: TrackerCoreData, with completionDate: String) throws {
        try context.performAndWait {
            guard let record = tracker.records else { return }
            
            let request = TrackerCompletionDate.fetchRequest()
            request.predicate =  NSPredicate(format: "record == %@ AND date == %@", record, completionDate)
            
            if let dateToDelete = try context.fetch(request).first {
                context.delete(dateToDelete)
                try context.save()
            }
        }
    }
}


