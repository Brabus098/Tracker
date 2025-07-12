//  ChooseDayController.swift
import UIKit

final class ChooseDayController: UIViewController {
    
    // MARK: Properties
    private let tableWeekDays = UITableView()
    private let dayArray = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private let nameForNotification = NSNotification.Name(rawValue: "LabelUpdate")
    private var daysRepeatDictionary = [String:Any]()
    
    private lazy var readyButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.addAction(UIAction(handler: { _ in
            
            NotificationCenter.default.post(name: self.nameForNotification, object: nil, userInfo: self.daysRepeatDictionary)
            
            self.navigationController?.popViewController(animated: true)
            
        }), for: .touchUpInside)
        
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDaysDictionary()
        view.backgroundColor = .white
        setupNavigationTitle()
        setupTableWeekDays()
        addButtonConstraint()
        addTable()
    }
    
    // MARK: Methods
    
    private func setDaysDictionary(){
        dayArray.forEach { daysRepeatDictionary[$0] = false } // простовляем состояние false для switch по умолчанию
        daysRepeatDictionary["Категория"] = "Важное"
    }
    
    private func setupNavigationTitle(){
        navigationItem.hidesBackButton = true
        navigationItem.title = ""
        
        let titleContainerView = UIView()
        navigationItem.titleView = titleContainerView
        let label = UILabel()
        
        label.text = "Расписание"
        label.font = UIFont(name: "SFPro-Medium", size: 17)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: titleContainerView.centerXAnchor)
        ])
    }
    
    private func addButtonConstraint(){
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupTableWeekDays() {
        tableWeekDays.delegate = self
        tableWeekDays.dataSource = self
        tableWeekDays.layer.cornerRadius = 16
        tableWeekDays.layer.masksToBounds = true
        
        tableWeekDays.register(ChooseDayCell.self, forCellReuseIdentifier: "ChooseDayCell")
        
        tableWeekDays.separatorStyle = .singleLine
        tableWeekDays.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableWeekDays.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        tableWeekDays.isUserInteractionEnabled = true
    }
    
    private func addTable(){
        view.addSubview(tableWeekDays)
        tableWeekDays.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableWeekDays.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableWeekDays.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableWeekDays.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableWeekDays.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -39)
        ])
    }
}

extension ChooseDayController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseDayCell", for: indexPath) as? ChooseDayCell else { return UITableViewCell() }
        
        let day = dayArray[indexPath.row] // выбираем день недели который будет слева от switch
        cell.configurationCell(day: day)
        
        //  Обработчик замыкание у ячейки сохраняет выбранное пользователем состояние switch
        cell.switcherChangedHandler = { [weak self, weak cell] status in
            guard let self = self, let cell = cell else { return }
            guard let actualIndexPath = tableView.indexPath(for: cell) else { return }
            
            let actualDay = self.dayArray[actualIndexPath.row]
            self.daysRepeatDictionary["\(actualDay)"] = status // фиксируем состоние ячейки
        }
        
        // Настройка внешнего вида
        cell.backgroundColor = .backgroundDay
        cell.selectionStyle = .none
        if indexPath.row == dayArray.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let totalRows = CGFloat(dayArray.count)
        let tableHeight = tableView.frame.height
        return tableHeight / totalRows
    }
}

extension ChooseDayController: UITableViewDelegate {
    
}
