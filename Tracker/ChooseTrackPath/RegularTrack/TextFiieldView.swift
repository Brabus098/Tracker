//  TextFieldView.swift

import UIKit

protocol CustomTextFieldProtocol: UIView {
    func updateTitleWhenCloseTheKeyboard()
}

protocol TextFieldControllerProtocol: AnyObject{
    var titleOfTrack: String { get set }
    func updateTitle(title: String)
    func updateLayout(showLimit: Bool)
}

//  CustomTextField.swift

final class TextFieldView: UIView {
    
    weak var controller: TextFieldControllerProtocol?
    private var heightConstraint: NSLayoutConstraint?

    
    private lazy var nameOfTrack = {
        let textField = UITextView()
        
        textField.textContainerInset = UIEdgeInsets(top: 28, left: 16, bottom: 0, right: 62)
        textField.font = UIFont(name: "SFPro-Regular", size: 17)
        textField.backgroundColor = .backgroundDay
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private lazy var placeholderForTextView = {
        let text = UILabel()
        text.text = "Введите название трека"
        text.font = UIFont(name: "SFPro-Regular", size: 17)
        text.textColor = .lightGray
        text.translatesAutoresizingMaskIntoConstraints = false
        addSubview(text)
        return text
    }()
    
    private lazy var cleanTextButton = {
        let cleanButton = UIButton()
        
        cleanButton.setImage(UIImage(named: "CleanButton"), for: .normal)

        cleanButton.isHidden = true
        cleanButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        cleanButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        cleanButton.addAction(UIAction(handler: {[weak self] _ in
            self?.placeholderForTextView.isHidden = false
            cleanButton.isHidden = true
            self?.nameOfTrack.text = nil
            self?.controller?.updateLayout(showLimit: false)

        }), for: .touchUpInside)
        
        addSubview(cleanButton)
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        
        return cleanButton
    }()
    
    
    required init(controller: TextFieldControllerProtocol) {
         self.controller = controller
         super.init(frame: .zero)
         setupConstraints()
         nameOfTrack.delegate = self
     }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameOfTrack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            nameOfTrack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            nameOfTrack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            nameOfTrack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            placeholderForTextView.leadingAnchor.constraint(equalTo: nameOfTrack.leadingAnchor, constant: 20),
            placeholderForTextView.topAnchor.constraint(equalTo: nameOfTrack.topAnchor, constant: 27),
            placeholderForTextView.bottomAnchor.constraint(equalTo: nameOfTrack.bottomAnchor, constant: -27),
            
            cleanTextButton.trailingAnchor.constraint(equalTo: nameOfTrack.trailingAnchor, constant: -16),
                 cleanTextButton.centerYAnchor.constraint(equalTo: nameOfTrack.centerYAnchor)
        ])
    }
}

// MARK: UITextView Delegate
extension TextFieldView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeholderForTextView.isHidden = true
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        changeValue()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {  // Если нажат Return
            textView.resignFirstResponder()
            cleanTextButton.isHidden = false
            
            controller?.updateTitle(title: self.nameOfTrack.text)
            return false
        }
        return true
    }
    
    // метод ограничивающий количество символов на вввод
    @objc private func changeValue(){
        if let textCount = nameOfTrack.text?.count {
            
            if textCount == 0 && nameOfTrack.text.isEmpty{
                placeholderForTextView.isHidden = false
                cleanTextButton.isHidden = true
                
            } else if textCount > 0 {
                print("Видна")
                placeholderForTextView.isHidden = true
                cleanTextButton.isHidden = false
            }
            
            if textCount > 38 {
                controller?.updateLayout(showLimit: true)
                
            } else {
                controller?.updateLayout(showLimit: false)
            }
        }
    }
}

extension TextFieldView: CustomTextFieldProtocol{
    func updateTitleWhenCloseTheKeyboard(){
        print("Поняли что нужно обновлять")
        cleanTextButton.isHidden = true
        controller?.updateTitle(title: self.nameOfTrack.text)
    }
}
