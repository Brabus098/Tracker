//  TrackerStoreWriterProtocol.swift

protocol TrackerWriterProtocol: AnyObject {
    func createTracker(_ tracker: Tracker, category: TrackerCategoryCoreData, dateOfCreated: String?) throws -> TrackerCoreData
}
