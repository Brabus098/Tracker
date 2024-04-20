import CoreData

final class TrackerStoreWriter: TrackerWriterProtocol {
    
    private let context: NSManagedObjectContext
    private let recordStore: TrackerRecordStoreProtocol
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context,
         recordStore: TrackerRecordStoreProtocol) {
        self.context = context
        self.recordStore = recordStore
    }
    
    // Метод создает трек по данным из формы и добвлет в БД
    func createTracker(_ tracker: Tracker, category: TrackerCategoryCoreData, dateOfCreated: String? = nil) throws -> TrackerCoreData {
        try context.performAndWait {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = Int16(tracker.id)
            trackerCoreData.name = tracker.name
            trackerCoreData.color = tracker.color
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.category = category
            
            // Добвлена новая развилка для разделения регулирных и нерегулярных треков
            if tracker.timeTable.dayOfWeek.isEmpty {
                trackerCoreData.isRegular = false
                let timeTable = TimeTableCoreData(context: context)
                timeTable.dayCount = 0
                timeTable.tracker = trackerCoreData
                trackerCoreData.creationDate = dateOfCreated
            } else {
                trackerCoreData.isRegular = true
                trackerCoreData.creationDate = ""
                setupTimeTable(for: tracker, trackerCoreData: trackerCoreData)
            }
            
            return trackerCoreData
        }
    }
    
    // Метод сохраняет дни для повторения привычки
    private func setupTimeTable(for tracker: Tracker, trackerCoreData: TrackerCoreData) {
        let timeTable = TimeTableCoreData(context: context)
        timeTable.dayCount = Int32(tracker.timeTable.dayCount)
        timeTable.tracker = trackerCoreData
        
        for day in tracker.timeTable.dayOfWeek {
            let weekDay = WeekDayCoreData(context: context)
            weekDay.dayName = day.rawValue
            weekDay.order = Int16(day.toWeekDays()?.rawValue ?? 0)
            weekDay.timetable = timeTable
            timeTable.addToWeekDays(weekDay)
        }
    }
}
