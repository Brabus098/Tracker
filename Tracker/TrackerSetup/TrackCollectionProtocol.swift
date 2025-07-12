//  TrackCollectionProtocol.swift

import UIKit

protocol TrackCollectionProtocol: AnyObject {
    var collection: UICollectionView { get } // настройка свойств
    
    func configure(collection dataBase: [TrackerCategory], // добавление треков
                   controllerForCollection: TrackCollectionActionDelegate,
                   completedTrackers: [TrackerRecord])
    
    func reloadData(with categories: [TrackerCategory], and trackRecords: [TrackerRecord], choseDate: Date) // обновление элементов ячейки
}
