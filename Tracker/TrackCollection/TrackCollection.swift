//  TrackCollection.swift

import UIKit

final class TrackCollection: NSObject, UICollectionViewDataSource {
    
    var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    let paramsForTrack = GeometricParams(cellCount: 2, leftInsert: 16, rightInsert: 16, cellSpacing: 9)
    
    weak var actionDelegate: TrackCollectionActionDelegate? // делегат для передачи инфы о нажатии на кнопку
    
    // MARK: DataSource
    var actualCategories = [TrackerCategory]()
    var actualTrackRecords = [TrackerRecord]()
    var currentDate: Date = Date() // выбранная дата
    
    // MARK: Setup Collection
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        actualCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        actualCategories[section].trackerArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else{
            return CollectionViewCell()
        }
        
        cell.delegate = self
        
        // Подготовка данных для передачи в ячейку
        let goalTextArray = actualCategories[indexPath.section].trackerArray
        let goalText = goalTextArray[indexPath.row].name
        let id = goalTextArray[indexPath.row].id
        let counter = goalTextArray[indexPath.row].timeTable.dayCount // счетчик с выполнеными днями
        let buttonState = createButtonState(id: id)
        
        cell.configurateCell(goalText: goalText, indexPath: indexPath, trackerId: id, counter: counter, button: buttonState)
        
        return cell
    }
    
    private func createButtonState(id: UInt) -> ButtonState {
        // Настройка состояния кнопки
        let actualDate = Date()
        var buttonState: ButtonState = .normal
        
        // Проверка: выбрана ли корректная дата
        if currentDate > actualDate {
            buttonState = .unActive
            // Проверка: если дата корректная то содержится ли для этого id выбранная дата, если да меняем состояние на выполненное
        } else if actualTrackRecords.contains(where: { $0.id == id && $0.trackCompletionDate.contains(currentDate.formatted()) }) {
            buttonState = .selected
        }
        return buttonState
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
        let headerText = actualCategories[indexPath.section].title
        
        view.configure(header: headerText)
        return view
    }
    
    // Метод настривает размер хедера
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
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

extension TrackCollection: TrackCollectionProtocol{
    
    func configure(collection dataBase: [TrackerCategory], controllerForCollection: TrackCollectionActionDelegate, completedTrackers: [TrackerRecord]) {
        actionDelegate = controllerForCollection
        collection.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.register(HeaderViewForCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.dataSource = self
        collection.delegate = self
        actualCategories = dataBase
        actualTrackRecords = completedTrackers
    }
    
    func reloadData(with categories: [TrackerCategory], and trackRecords: [TrackerRecord], choseDate: Date) {
        actualCategories = categories
        actualTrackRecords = trackRecords
        currentDate = choseDate
        collection.reloadData()
    }
    
    func reloadRows(newData: [TrackerCategory], section: Int, choseDate: Date, trackerRecords: [TrackerRecord]) {
        
        actualCategories = newData
        actualTrackRecords = trackerRecords
        currentDate = choseDate
        
        let oldCount = actualCategories[section].trackerArray.count
        let newCount = actualCategories[section].trackerArray.count
        
        collection.performBatchUpdates {
            if newCount > oldCount {
                let indexes = (oldCount..<newCount).map { IndexPath(item: $0, section: section) }
                collection.insertItems(at: indexes)
            } else if newCount < oldCount {
                let indexes = (newCount..<oldCount).map { IndexPath(item: $0, section: section) }
                collection.deleteItems(at: indexes)
            }
        }
    }
}

extension TrackCollection: TrackerCellDelegate {
    func didTapPlusButton(for trackerId: UInt) {
        actionDelegate?.didCompleteTracker(trackerId) // оповещаем делегата о наступлении события
    }
}

