//  TrackerCellDelegate.swift

protocol TrackerCellDelegate: AnyObject {
    func didTapPlusButton(for trackerId: UInt) // ячейка оповещает коллекцию о нажатии
}

// Описывает возможное состояние кнопки - "Трек выполнен" в ячейке
enum ButtonState {
    case normal
    case selected
    case unActive
}
