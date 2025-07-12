//  TrackCollectionActionDelegate.swift

protocol TrackCollectionActionDelegate: AnyObject {
    func didCompleteTracker(_ trackerId: UInt) // колекция оповещает контроллер о нажатии
}
