//  TrackCollectionProtocol.swift

import UIKit

protocol TrackCollectionProtocol: AnyObject {
    var collection: UICollectionView { get } // настройка свойств
    var currentDate: Date { get set }
    func configure(controllerForCollection: TrackCollectionActionDelegate)
    func reloadDataInCollection() // обновление элементов ячейки
    func updateForDay(_ day: Int) -> Int
    func findText(title: String, store: TrackerStoreReader)
    func changeFilter(day: Int)
}
