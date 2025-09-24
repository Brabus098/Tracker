//  EditCategoryTitleController.swift

import Foundation
import UIKit

final class EditCategoryTitleController: UIViewController {
    
    private var viewModel: CreateCategoryViewModel? // для передачи сохраненой категории
    private var newNameForTitle: String = ""
    var titleOfTrack: String
    
    private lazy var readyButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.backgroundColor = UIColor.blackDay.cgColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.addAction(UIAction(handler: {[weak self] _ in
            
            // Изменение данных введенных пользователем
            self?.viewModel?.edit(oldCategory: self?.titleOfTrack ?? "", from: self?.newNameForTitle ?? "")
            
            // Переход к экрану созданых категорий
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var textFieldView: CustomTextFieldProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupMainActorViews()
        setupConstraint()
        setupKeyboard()
    }
    
    init(viewModel: CreateCategoryViewModel? = nil, titleForEdit: String) {
        self.viewModel = viewModel
        self.titleOfTrack = titleForEdit
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(){
        viewModel?.newTitle = { [weak self] newTitle in
            self?.updateTitle(title: newTitle)
        }
    }
    
    private func setupMainActorViews(){
        textFieldView = TextFieldView(viewModel: viewModel ?? CreateCategoryViewModel(model: CreateCategoryModel()))
        textFieldView?.removePlaceholderText(load: titleOfTrack)
    }
    
    private func setupNavigationTitle(){
        navigationItem.hidesBackButton = true
        navigationItem.title = ""
        
        view.backgroundColor = .white
        
        let titleContainerView = UIView()
        navigationItem.titleView = titleContainerView
        let label = UILabel()
        
        label.text = "Редактирование категории"
        label.font = UIFont(name: "SFPro-Medium", size: 17)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: titleContainerView.centerXAnchor)
        ])
    }
    
    private func setupConstraint(){
        guard let textFieldView else { return }
        
        view.addSubview(textFieldView)
        
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            // Ready Button
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            
            textFieldView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
        ])
    }
}

extension EditCategoryTitleController: TextFieldControllerProtocol {
    
    // метод обновляет начзвание трека - реагирует на байдинг titleOfTrack
    func updateTitle(title: String){
        newNameForTitle = title
    }
    
    func updateLayout(showLimit: Bool) {}
}

// Keyboard methods
extension EditCategoryTitleController {
    private func setupKeyboard(){
        let tapCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        tapCloseKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapCloseKeyboard)
    }
    
    @objc private func closeKeyBoard(){
        view.endEditing(true)
        textFieldView?.updateTitleWhenCloseTheKeyboard()
    }
}
