//  TrackCollection.swift

import UIKit
import CoreData

final class TrackCollection: NSObject, UICollectionViewDataSource {
    
    var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    var currentDate: Date = Date()
    private let paramsForTrack = GeometricParams(cellCount: 2, leftInsert: 16, rightInsert: 16, cellSpacing: 9)
    
    weak var actionDelegate: TrackCollectionActionDelegate?
    
    // MARK: Storeы
    private let trackerStore: TrackerStoreReader
    private let recordStore: TrackerRecordStoreProtocol
    
    init(trackerStore: TrackerStoreReader,
         recordStore: TrackerRecordStoreProtocol) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        super.init()
    }
    
    // MARK: DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else { return CollectionViewCell() }
        cell.delegate = self
        
        guard let tracker = trackerStore.tracker(at: indexPath) else { print("[TrackCollection]: Коллекции не удалось вызвать трекер")
            return cell }
        let buttonState = createButtonState(id: Int16(tracker.id))
        
        cell.configurateCell(
            goalText: tracker.name,
            indexPath: indexPath,
            trackerId: Int16(tracker.id),
            counter: Int32(tracker.timeTable.dayCount),
            button: buttonState,
            emoji: tracker.emoji,
            color: tracker.color.toUIColor()
        )
        return cell
    }
    
    private func createButtonState(id: Int16) -> ButtonState {
        let actualDate = Date()
        var buttonState: ButtonState = .normal
        let checkResult = trackerStore.checkContainsDate(id: id, date: currentDate.formatted().dataFormatter())
        
        if currentDate > actualDate {
            buttonState = .unActive
        } else if checkResult {
            buttonState = .selected
        }
        return buttonState
    }
}
extension TrackCollection: TrackCollectionProtocol {
    
    func configure(controllerForCollection: TrackCollectionActionDelegate) {
        actionDelegate = controllerForCollection
        collection.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.register(HeaderViewForCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.dataSource = self
        collection.delegate = self
        trackerStore.delegate = self
    }
    // метод обновляет состояние кнопки
    func reloadDataInCollection() {
        collection.reloadData()
    }
}

extension TrackCollection: TrackerCellDelegate {
    func didTapPlusButton(for trackerId: UInt) {
        actionDelegate?.didCompleteTracker(trackerId)
    }
}

extension TrackCollection: TrackerStoreDelegate {
    // метод обновления коллекция вызываемый FRC
    func didUpdateData() {
        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }
}

// MARK: DelegateFlowLayout
extension TrackCollection: UICollectionViewDelegateFlowLayout{
    
    // Метод определяет количество треков в ряду
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - paramsForTrack.paddingWidth
        let cellWidth = availableWidth / CGFloat(paramsForTrack.cellCount)
        
        return CGSize(width: cellWidth, height: 148)
    }
    
    // Метод определяет отступ между треками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(paramsForTrack.cellSpacing)
    }
    
    // Метод настривает блок хедера
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let id: String
        
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = collection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? HeaderViewForCell else { return UICollectionReusableView()}
        
        let headerText = trackerStore.titleForSection(indexPath.section)
        
        view.configure(header: headerText)
        return view
    }
    
    // Метод настраивает размер хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = HeaderViewForCell(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 0))
        headerView.configure(header: "Header")
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    // Метод задает отстутпы от краев колекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: -10, right: 16)
    }
}

// MARK: Filtres methods
extension TrackCollection {
    // Метод вызываемый контроллером
    func updateForDay(_ day: Int) -> Int{
        // Обновляем фильтр в FRC
        let countTrackForThisDay = trackerStore.updateFilterForDay(day)
        
        // Перезагружаем коллекцию
        collection.reloadData()
        
        return countTrackForThisDay
    }
    func findText(title: String, store: TrackerStoreReader) {
        guard var result = trackerStore.findText(element: title) else { return  }
        actionDelegate?.changeStateCollection(status: result > 0)
    }
    
    func changeFilter(day: Int){
        trackerStore.updateFilterForDay(day)
    }
}
