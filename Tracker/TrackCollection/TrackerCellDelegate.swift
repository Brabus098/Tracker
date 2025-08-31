//  TrackerCellDelegate.swift

protocol TrackerCellDelegate: AnyObject {
    func didTapPlusButton(for trackerId: UInt) // ячейка оповещает коллекцию о нажатии
}
