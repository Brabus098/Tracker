//  MenuView.swift

import UIKit

final class MenuView: UIView {
    private var tableView = UITableView()
    private var tableDataBaseActions: [String]
    private var chooseCategoryTitle: String
    weak var delegate: CustomMenuDelegate?
    
    init(tableDataBaseActions: [String], delegate: CustomMenuDelegate, chooseCategoryTitle: String) {
        self.tableDataBaseActions = tableDataBaseActions
        self.delegate = delegate
        self.chooseCategoryTitle = chooseCategoryTitle
        super.init(frame: .zero)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 13
        tableView.separatorStyle = .none
        tableView.register(MenuCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        tableView.backgroundColor = .backgroundDay
        tableView.rowHeight = 48
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension MenuView: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableDataBaseActions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath) as? MenuCell else { return UITableViewCell()}
        
        let text = tableDataBaseActions[indexPath.row]
        cell.configurationCell(text: text)
        
        if tableDataBaseActions[indexPath.row] == "Удалить" {
            cell.changeLabelColor()
        }
        return cell
    }
    
}

extension MenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDataBaseActions[indexPath.row] {
            
        case "Редактировать" : delegate?.choose(action: .edit, chooseTitle: chooseCategoryTitle)
        case "Удалить": delegate?.choose(action: .delete, chooseTitle: chooseCategoryTitle)
        case "Закрепить": delegate?.choose(action: .fix, chooseTitle: chooseCategoryTitle)
        case "Открепить": delegate?.choose(action: .unFix, chooseTitle: chooseCategoryTitle)
            
        default:
            print("[MenuView]: рандомное значение в меню!")
        }
    }
}
