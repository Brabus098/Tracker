//  CreateCategoryController.swift

import UIKit

final class CreateCategoryController: UIViewController {
    
    var titleOfTrack = String()
    private var textFieldView: CustomTextFieldProtocol?
    
    private lazy var restrictionCount = {
        var label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        
        return label
    }()
    
    private lazy var readyButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.backgroundColor = UIColor.grey.cgColor
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.layer.cornerRadius = 16
        
        button.addAction(UIAction(handler: {[weak self] _ in
            
            // Сохранение данных введенных пользователем
            self?.viewModel?.save(title: self?.titleOfTrack ?? "")
            
            // Переход к экрану созданных категорий
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // View model Bindings
    private var viewModel: CreateCategoryViewModel? // для передачи сохраненой категории
    
    func initialize(viewModel: CreateCategoryViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    func bind(){
        viewModel?.limitLabelStatus = { [weak self] limitStatus in
            self?.updateLayout(showLimit: limitStatus)
        }
        
        viewModel?.newTitle = { [weak self] newTitle in
            self?.updateTitle(title: newTitle)
            self?.titleOfTrack = newTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainActorViews()
        setupNavigationTitle()
        setupConstraint()
        setupKeyboard()
    }
    
    private func setupMainActorViews(){
        textFieldView = TextFieldView(viewModel: viewModel ?? CreateCategoryViewModel(model: CreateCategoryModel()))
        textFieldView?.changePlaceholderTitle()
    }
    
    private func setupNavigationTitle(){
        navigationItem.hidesBackButton = true
        navigationItem.title = ""
        
        view.backgroundColor = .white
        
        let titleContainerView = UIView()
        navigationItem.titleView = titleContainerView
        let label = UILabel()
        
        label.text = "Новая категория"
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
        view.addSubview(restrictionCount)
        
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            
            textFieldView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            restrictionCount.topAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: 8),
            restrictionCount.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 29),
            restrictionCount.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -29)
        ])
    }
}

extension CreateCategoryController: TextFieldControllerProtocol {
    
    // метод обновляет начзвание трека - реагирует на биндинг titleOfTrack
    func updateTitle(title: String){
        titleOfTrack = title
        if !title.isEmpty {
            readyButton.layer.backgroundColor = UIColor.blackDay.cgColor
            readyButton.isEnabled = true
        } else {
            readyButton.layer.backgroundColor = UIColor.grey.cgColor
            readyButton.isEnabled = false
        }
    }
    
    // Метод обновляет высоту строк при показе ограничителя - реагирует на байдинг limitLabel
    func updateLayout(showLimit: Bool) {
        restrictionCount.isHidden = !showLimit
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// KeyBoard methods
extension CreateCategoryController {
    private func setupKeyboard(){
        let tapCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        tapCloseKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapCloseKeyboard)
    }
    
    @objc func closeKeyBoard(){
        view.endEditing(true)
        textFieldView?.updateTitleWhenCloseTheKeyboard()
    }
}
