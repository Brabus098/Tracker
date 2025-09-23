//  CustomMenuDelegate.swift

protocol CustomMenuDelegate: AnyObject {
    func choose(action isWas: MenuActions, chooseTitle: String)
}
