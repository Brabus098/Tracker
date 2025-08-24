//  TrackerReaderProtocol.swift

import Foundation

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateData()
}

protocol TrackerReaderProtocol: AnyObject {
    var delegate: TrackerStoreDelegate? { get set }
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func titleForSection(_ section: Int) -> String
    func updateFilter(for day: Int) -> Int
    func checkContainsDate(id: Int16, date: String) -> Bool
    func loadTrackers() -> [TrackerCategory]
}
