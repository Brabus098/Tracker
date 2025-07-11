//  UnRegularController.swift

import UIKit

final class UnRegularController: UIViewController {
    
    // Замыкание, принимающее данные (TrackerCategory)
    var onDataCreated: (([TrackerCategory]) -> Void)?
    
    // MARK: Properties
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private let table = UITableView()
    
    // MARK: DataBase properties
    private var dataBase = ["Категория"]
    private var categoryForTracks = [TrackerCategory]() // для сохранения новых трекеров и их последующей передачи
    private var categoryTitle = String() // для сохранения названия категории
    private var titleOfTrack = "" // для сохранения названия трека
    
    private lazy var cancelButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        
        button.addAction(UIAction(handler: { [weak self] _ in
            print("Отмена")
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var saveButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.backgroundColor = UIColor.grey.cgColor
        
        button.addAction(UIAction(handler: { [weak self] _ in
            
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var nameOfTrack = {
        let textField = UITextView()
        
        //        textField.leftView = paddingView
        //        textField.leftViewMode = .always
        //        textField.placeholder = "Введите название трека"
        textField.textContainerInset = UIEdgeInsets(top: 28, left: 16, bottom: 0, right: 62)
        textField.font = UIFont(name: "SFPro-Regular", size: 17)
        textField.backgroundColor = .backgroundDay
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private lazy var cleanTextButton = {
        let cleanButton = UIButton()
        
        cleanButton.setImage(UIImage(named: "CleanButton"), for: .normal)
        cleanButton.isHidden = true
        cleanButton.addAction(UIAction(handler: {[weak self] _ in
            self?.placeholderForTextView.isHidden = false
            cleanButton.isHidden = true
            self?.nameOfTrack.text = nil
            self?.restrictionCount.isHidden = true
            self?.topConstraint?.constant = 24
            self?.bottomConstraint?.constant = -430
            
            UIView.animate(withDuration: 0.1) {
                self?.view.layoutIfNeeded()
            }
        }), for: .touchUpInside)
        
        view.addSubview(cleanButton)
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        
        return cleanButton
    }()
    
    private lazy var placeholderForTextView = {
        let text = UILabel()
        text.text = "Введите название трека"
        text.font = UIFont(name: "SFPro-Regular", size: 17)
        text.textColor = .lightGray
        text.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text)
        return text
    }()
    
    private lazy var restrictionCount = {
        var label = UILabel()
        label.text = "Ограничение 38 символов"
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.table.centerXAnchor),
            label.topAnchor.constraint(equalTo: self.nameOfTrack.bottomAnchor, constant: 9),
            table.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24)
        ])
        label.isHidden = false
        
        topConstraint?.constant = 62
        bottomConstraint?.constant = -380
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        return label
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setupTable()
        constraintForViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: Methods
    
    private func configureViews(){
        view.backgroundColor = .white
        
        setupNameOfTrackLabel()
        setupKeyboard()
        setupNavigationTitle()
    }
    
    private func setupNameOfTrackLabel(){
        
        nameOfTrack.delegate = self
        //        nameOfTrack.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        //        nameOfTrack.addTarget(self, action: #selector(changeValue), for: .editingChanged)
    }
    
    private func setupKeyboard(){
        let tapCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        tapCloseKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapCloseKeyboard)
    }
    private func setupNavigationTitle(){
        navigationItem.title = ""
        
        let titleContainer = UIView()
        navigationItem.titleView = titleContainer
        let titleLabel = UILabel()
        
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 17)
        titleLabel.text = "Новое регулярное событие"
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 20)
        ])
        
        navigationItem.hidesBackButton = true
    }
    
    @objc private func closeKeyBoard(){
        cleanTextButton.isHidden = true
        view.endEditing(true)  // Скрывает клавиатуру для всех полей
        titleOfTrack = self.nameOfTrack.text
        
    }
    
    @objc private func editingDidEnd() {
        cleanTextButton.isHidden = true
    }
    
    private func setupTable(){
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.separatorStyle = .none // Включаем разделители
        
        //
        //                //Временно:
        //                        table.layer.borderWidth = 2
        //                        table.layer.borderColor = UIColor.red.cgColor
        
        // Убираем верхний разделитель таблицы
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        table.isUserInteractionEnabled = true
        table.dataSource = self
        table.delegate = self
        table.register(RegularTrackCell.self, forCellReuseIdentifier: "RegularTrackCell")
    }
    
    private func constraintForViews(){
        
        NSLayoutConstraint.activate([
            nameOfTrack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameOfTrack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameOfTrack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            nameOfTrack.heightAnchor.constraint(equalToConstant: 75),
            
            cleanTextButton.centerYAnchor.constraint(equalTo: nameOfTrack.centerYAnchor),
            cleanTextButton.topAnchor.constraint(equalTo: nameOfTrack.topAnchor, constant: 29),
            cleanTextButton.trailingAnchor.constraint(equalTo: nameOfTrack.trailingAnchor, constant: -12),
            
            placeholderForTextView.leadingAnchor.constraint(equalTo: nameOfTrack.leadingAnchor, constant: 20),
            placeholderForTextView.topAnchor.constraint(equalTo: nameOfTrack.topAnchor, constant: 27),
            placeholderForTextView.bottomAnchor.constraint(equalTo: nameOfTrack.bottomAnchor, constant: -26),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            saveButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            
            table.leadingAnchor.constraint(equalTo: nameOfTrack.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: nameOfTrack.trailingAnchor),
        ])
        
        let tableHeightConstraint = table.heightAnchor.constraint(greaterThanOrEqualToConstant: 75)
        tableHeightConstraint.priority = .defaultLow
        tableHeightConstraint.isActive = true
        
        let maxHeightConstraint = table.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.4)
        maxHeightConstraint.isActive = true
        
        self.topConstraint = table.topAnchor.constraint(equalTo: nameOfTrack.bottomAnchor, constant: 24)
        self.topConstraint?.isActive = true
        self.bottomConstraint?.isActive = true
    }
}

// MARK: Methods limiting the number of characters in the input
extension UnRegularController {
    
    @objc private func changeValue(){
        if let textCount = nameOfTrack.text?.count {
            
            if textCount == 0 && nameOfTrack.text.isEmpty{
                placeholderForTextView.isHidden = false
                cleanTextButton.isHidden = true
            } else if textCount > 0 {
                placeholderForTextView.isHidden = true
                
                saveButton.backgroundColor = .blackDay
                cleanTextButton.isHidden = false
            }
            
            if textCount > 38 {
                restrictionCount.isHidden = false
                restrictionCount.textColor = .red
                
                topConstraint?.constant = 62
                bottomConstraint?.constant = -380
                
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            } else {
                restrictionCount.isHidden = true
                topConstraint?.constant = 24
                bottomConstraint?.constant = -495
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

// MARK: Setup TableView
extension UnRegularController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataBase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RegularTrackCell", for: indexPath) as? RegularTrackCell else { return UITableViewCell()}
        
        cell.configurateText(ForLabel: dataBase[indexPath.row])
        cell.backgroundColor = UIColor(named: "BackgroundDay")
        
        cell.layer.cornerRadius = 16
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if dataBase[indexPath.row] == "Категория" {
            
        }
    }
}

// MARK: UITextView Delegate
extension UnRegularController: UITextViewDelegate {
    
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
            cleanTextButton.isHidden = true
            titleOfTrack = text
            titleOfTrack = self.nameOfTrack.text
            return false
        }
        return true
    }
}

