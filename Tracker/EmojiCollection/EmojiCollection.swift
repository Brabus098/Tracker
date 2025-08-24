//  EmojiCollection.swift

protocol EmojiCollectionProtocol: AnyObject {
    var emojiCollection: UICollectionView { get }
    func configurateEmojiCollection()
    var paramsForTrack: GeometricParams { get }
    var emojiArray: [String] { get }
    var chooseEmoji: String { get }
}

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
        
        cell.configurateCell(emoji: emojiArray[indexPath.row])
        
        return cell
    }
}

// MARK: Delegat
extension EmojiCollection: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection = collectionView.cellForItem(at: indexPath)
        collection?.contentView.backgroundColor = .lightGrey
        collection?.contentView.layer.cornerRadius = 16
        collection?.layer.masksToBounds = true
        
        self.chooseEmoji = emojiArray[indexPath.row]
        
        print("Выбранный эмоджи - \(self.chooseEmoji)")
        print("Конснулись ячейки")
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


//        NSLayoutConstraint.activate([
//            // Эмодзи коллекция
//            emojiC.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 32),
//            emojiC.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            emojiC.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            // Цветовая коллекция
//            colorC.topAnchor.constraint(equalTo: emojiC.bottomAnchor, constant: 16),
//            colorC.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            colorC.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            colorC.bottomAnchor.constraint(lessThanOrEqualTo: cancelButton.topAnchor, constant: -16),
//        ])

