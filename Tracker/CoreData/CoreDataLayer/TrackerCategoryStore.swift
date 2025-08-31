// TrackerCategoryStore.swift
import CoreData

final class TrackerCategoryStore { // класс отвечает за доступ к TrackerCategory
    let context: NSManagedObjectContext
    private let trackerWriter: TrackerWriterProtocol
    private let trackerRider: TrackerReaderProtocol
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context,
         trackerWriter: TrackerWriterProtocol, trackerRider: TrackerReaderProtocol) {
        self.context = context
        self.trackerWriter = trackerWriter
        self.trackerRider = trackerRider
    }
    
    func addNewTrackerCategory(_ categories: [TrackerCategory]) throws {
        try context.performAndWait {
            
            for category in categories {
                let categoryCoreData = TrackerCategoryCoreData(context: context)
                categoryCoreData.title = category.title
                
                for tracker in category.trackerArray {
                    // если в этой категории трека с таким id нету, создаем его
                    if !checkAdded(trackWithId: tracker) {
                        let trackerCoreData = try trackerWriter.createTracker(tracker, category: categoryCoreData)
                        categoryCoreData.addToTracker(trackerCoreData)
                    }
                }
            }
            try context.save()
        }
    }
    
    // Метод проверяет существует ли трек с таки id
    private func checkAdded(trackWithId tracker: Tracker) -> Bool {
        let actualArrayAtDataBase = trackerRider.loadTrackers()
        
        return actualArrayAtDataBase.contains {
            $0.trackerArray.contains { $0.id == tracker.id }
        }
    }
}
