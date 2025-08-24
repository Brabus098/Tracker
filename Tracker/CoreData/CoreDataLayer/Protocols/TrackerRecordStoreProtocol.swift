//  TrackerRecordStoreProtocol.swift

protocol TrackerRecordStoreProtocol {
    func createRecord(for tracker: TrackerCoreData, with completionDate: String) throws
    func deleteRecord(for tracker: TrackerCoreData, with completionDate: String) throws
}
