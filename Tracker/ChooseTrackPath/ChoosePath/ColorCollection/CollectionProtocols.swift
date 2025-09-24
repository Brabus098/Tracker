//  CollectionProtocols.swift

import UIKit

protocol ColorCollectionProtocol: AnyObject {
    var colorCollection: UICollectionView { get }
    func configColorCollection()
    var paramsForTrack: GeometricParams { get }
    var colorArray: [UIColor] { get }
    var chooseColor: String { get }
    func updateChooseColor(at: String)
}

protocol EmojiCollectionProtocol: AnyObject {
    var emojiCollection: UICollectionView { get }
    func configurateEmojiCollection()
    var paramsForTrack: GeometricParams { get }
    var emojiArray: [String] { get }
    var chooseEmoji: String { get set}
    func updateChooseEmoji(at emoji: String)
}
