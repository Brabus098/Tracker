//  TrackCollectionActionDelegate.swift
import Foundation

protocol TrackCollectionActionDelegate: AnyObject {
    func didCompleteTracker(_ trackerId: UInt) // колекция оповещает контроллер о нажатии
    func changeStateCollection(status: Bool)
    func showNotFoundImage(status: Bool)
    func giveActualDate() -> Date
<<<<<<< HEAD
    func makeCollectionInvisible(count: Int)
=======
>>>>>>> a0411ad26fce5a99c6cf797e5eb5b660f15b8072
}
