//  TrackCollectionActionDelegate.swift
import Foundation

protocol TrackCollectionActionDelegate: AnyObject {
    func didCompleteTracker(_ trackerId: UInt) // колекция оповещает контроллер о нажатии
    func changeStateCollection(status: Bool)
    func showNotFoundImage(status: Bool)
    func giveActualDate() -> Date
}
