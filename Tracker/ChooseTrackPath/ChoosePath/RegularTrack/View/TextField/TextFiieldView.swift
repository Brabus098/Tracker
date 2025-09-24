//  CustomTextField.swift

import UIKit

final class TextFieldView: UIView {
    
    weak var viewModel: TextFieldViewModelProtocol?
    
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
            self?.viewModel?.updateLayout(and: false)
            
        }), for: .touchUpInside)
        
        addSubview(cleanButton)
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        
        return cleanButton
    }()
    
    required init(viewModel: TextFieldViewModelProtocol) {
        self.viewModel = viewModel
        
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
        cleanTextButton.isHidden = false
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        changeValue()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {  // Если нажат Return
            textView.resignFirstResponder()
            cleanTextButton.isHidden = false
            
            viewModel?.update(title: self.nameOfTrack.text)
            
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel?.update(title: self.nameOfTrack.text)
    }
    
    // метод ограничивающий количество символов на вввод
    @objc private func changeValue(){
        if let textCount = nameOfTrack.text?.count {
            
            if textCount == 0 && nameOfTrack.text.isEmpty{
                placeholderForTextView.isHidden = false
                cleanTextButton.isHidden = true
                
            } else if textCount > 0 {
                placeholderForTextView.isHidden = true
                cleanTextButton.isHidden = false
            }
            viewModel?.updateLayout(and: textCount > 38)
        }
    }
}

extension TextFieldView: CustomTextFieldProtocol {
    
    func editGoalOfTrack(with newName: String) {
        nameOfTrack.text = newName
        placeholderForTextView.isHidden = true
    }
    
    func updateTitleWhenCloseTheKeyboard(){
        cleanTextButton.isHidden = true
        viewModel?.update(title: self.nameOfTrack.text)
    }
    
    func changePlaceholderTitle(){
        placeholderForTextView.text = "Введите название категории"
    }
    
    func removePlaceholderText(load oldText: String){
        placeholderForTextView.text = " "
        nameOfTrack.text = oldText + "             "
    }
}
