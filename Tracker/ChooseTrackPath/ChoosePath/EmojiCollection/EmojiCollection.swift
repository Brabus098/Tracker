//  EmojiCollection.swift

import UIKit

final class EmojiCollection: NSObject {
    
    var emojiCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: Data Base
    let emojiArray = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    let paramsForTrack = GeometricParams(cellCount: 6, leftInsert: 18, rightInsert: 19, cellSpacing: 5)
    
    var chooseEmoji = ""
    private var selectedEmoji: String? = nil
    
}

// MARK: Data Source
extension EmojiCollection: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojiArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCollectionCell else {
            return CollectionViewCell()
        }
        
        //        cell.layer.borderColor = UIColor.red.cgColor
        //        cell.layer.borderWidth = 2
        // Настраиваем ячейку
        cell.contentView.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        let emoji = emojiArray[indexPath.row]
        
        // Выделяем если это выбранный эмоджи
        if emoji == selectedEmoji {
            cell.contentView.backgroundColor = .lightGrey
        } else {
            cell.contentView.backgroundColor = .clear
        }
        
        cell.configurateCell(emoji: emojiArray[indexPath.row])
        
        return cell
    }
    
    func updateChooseEmoji(at emoji: String) {
        selectedEmoji = emoji
        self.chooseEmoji = emoji
        
        emojiCollection.reloadData()
    }
}

// MARK: Delegat
extension EmojiCollection: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.chooseEmoji = emojiArray[indexPath.row]
        
        selectedEmoji = emojiArray[indexPath.row]
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let collection = collectionView.cellForItem(at: indexPath)
        collection?.contentView.backgroundColor = .clear
        
    }
}

// MARK: Flow Layout
extension EmojiCollection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - paramsForTrack.paddingWidth
        let cellWidth = availableWidth / CGFloat(paramsForTrack.cellCount)
        
        return CGSize(width: cellWidth, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "CreateTrackHeader"
        case UICollectionView.elementKindSectionFooter:
            id = "CreateTrackfooter"
        default:
            id = ""
        }
        
        guard let view = emojiCollection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? CreateTrackHeader else { return UICollectionReusableView()}
        
        view.configHeader(title: "Emoji")
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 50)
        
    }
}

// MARK: EmojiCollectionProtocol
extension EmojiCollection: EmojiCollectionProtocol {
    
    func configurateEmojiCollection(){
        emojiCollection.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollection.register(CreateTrackHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CreateTrackHeader")
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
    }
}
