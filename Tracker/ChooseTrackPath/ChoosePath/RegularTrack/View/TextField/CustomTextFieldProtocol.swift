//  CustomTextFieldProtocol.swift

import UIKit

protocol CustomTextFieldProtocol: UIView {
    func updateTitleWhenCloseTheKeyboard() // вызывается контрллером
    func changePlaceholderTitle()
    func removePlaceholderText(load oldText: String)
    func editGoalOfTrack(with newName: String)
}

protocol TextFieldControllerProtocol: AnyObject {
    var titleOfTrack: String { get set }
    func updateTitle(title: String)
    func updateLayout(showLimit: Bool)
}

protocol TextFieldViewModelProtocol: AnyObject {
    func update(title: String)
    func updateLayout(and showLimit: Bool)
}
