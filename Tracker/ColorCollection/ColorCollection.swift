//  ColorCollection.swift

protocol ColorCollectionProtocol: AnyObject {
    var colorCollection: UICollectionView { get }
    func configColorCollection()
    var paramsForTrack: GeometricParams { get }
    var colorArray: [UIColor] { get }
    var chooseColor: String { get }

}

import UIKit

final class ColorCollection: NSObject {
    
    lazy var colorCollection = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.minimumInteritemSpacing = 5
        collectionLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let newCollection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        return newCollection
    }()
    
    // MARK: DATA Base
    let colorArray = [UIColor.color1, UIColor.color2, UIColor.color3, UIColor.color4, UIColor.color5, UIColor.color6, UIColor.color7, UIColor.color8, UIColor.color9, UIColor.color10, UIColor.color11, UIColor.color12, UIColor.color13, UIColor.color14, UIColor.color15, UIColor.color16, UIColor.color17, UIColor.color18]
    
    let paramsForTrack = GeometricParams(cellCount: 6, leftInsert: 18, rightInsert: 19, cellSpacing: 5)
    
    var chooseUIColor: UIColor = .clear
    var chooseColor: String = ""
}

// MARK: Data Source
extension ColorCollection: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colorArray.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = colorCollection.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCell else { return CollectionViewCell()}
        cell.configurateCell(color: colorArray[indexPath.row])
        
        
        return cell
    }
}

// MARK: Delegat
extension ColorCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection = collectionView.cellForItem(at: indexPath)
        collection?.contentView.layer.cornerRadius = 8
        collection?.layer.masksToBounds = true

        collection?.contentView.layer.borderWidth = 3
        collection?.contentView.layer.borderColor = colorArray[indexPath.row].withAlphaComponent(0.3).cgColor
        
        // Достаем название цвета из индекса name
        self.chooseUIColor = colorArray[indexPath.row]
            let description = "\(self.chooseUIColor)"
            if let range = description.range(of: "name = [^;]+", options: .regularExpression) {
                let name = String(description[range].dropFirst(6).dropLast(1)).lowercased()
                self.chooseColor = name.filter({$0 != " "}) // сохдарняем итоговый результат
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let collection = collectionView.cellForItem(at: indexPath)
        collection?.contentView.backgroundColor = .clear
        collection?.contentView.layer.borderWidth = 0
    }
}

// MARK: Flow Layout
extension ColorCollection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - paramsForTrack.paddingWidth
        let cellWidth = availableWidth / CGFloat(paramsForTrack.cellCount)
        
        return CGSize(width: cellWidth, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let id: String
        
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            id = "CreateTrackHeader"
        case UICollectionView.elementKindSectionFooter:
            id = "CreateTrackFooter"
        default:
            id = ""
        }
        
        guard let view = colorCollection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? CreateTrackHeader else { return  UICollectionReusableView()}
        
        view.configHeader(title: "Цвет")
        return view
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

// MARK: ColorCollectionProtocol
extension ColorCollection: ColorCollectionProtocol {
    
    func configColorCollection(){
        colorCollection.register(ColorCell.self, forCellWithReuseIdentifier: "colorCell")
        colorCollection.register(CreateTrackHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CreateTrackHeader")
        colorCollection.dataSource = self
        colorCollection.delegate = self
   
    }
}
