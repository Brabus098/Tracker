//  TrackFilterController.swift

enum FiltersForTrackCollection: String {
    case allTracks = "Все трекеры"
    case trackForActualDate = "Трекеры на сегодня"
    case didTracks = "Завершенные"
    case unDidTracks = "Не завершенные"
}

import UIKit

final class TrackFilterController: UIViewController {
    
    private let filterTableView = UITableView()
    private let filterStateData = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
    weak var filterDelegate: FiltersProtocol?
    weak var actionWithFilterDelegate: ActionFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationTitle()
    }
    
    func setupView() {
        view.addSubview(filterTableView)
        
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        filterTableView.separatorStyle = .none
        filterTableView.layer.cornerRadius = 16
        filterTableView.layer.masksToBounds = true
        filterTableView.clipsToBounds = true
        
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        
        NSLayoutConstraint.activate([
            filterTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterTableView.heightAnchor.constraint(equalToConstant: 343)
        ])
    }
    
    private func setupNavigationTitle(){
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        navigationItem.title = ""
        
        let titleContainerView = UIView()
        navigationItem.titleView = titleContainerView
        let label = UILabel()
        
        label.text = "Фильтры"
        label.font = UIFont(name: "SFPro-Medium", size: 17)
        label.textColor = .blackDay
        
        label.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: titleContainerView.centerXAnchor)
        ])
    }
}

extension TrackFilterController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterStateData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        cell.setSeparatorHidden(indexPath.row == totalRows - 1)
        cell.configuration(title: filterStateData[indexPath.row])
        
        let filterState = filterDelegate?.chooseFilter.rawValue
        
        if filterState != filterStateData[indexPath.row] {
            cell.imageIs(hidden:true)
        } else {
            if filterState == "Все трекеры" || filterState == "Трекеры на сегодня" {
                cell.imageIs(hidden:true)
            } else {
                cell.imageIs(hidden: false)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let totalRows = CGFloat(filterStateData.count)
        let tableHeight = tableView.frame.height
        return tableHeight / totalRows
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
            print("[TrackFilterController]: не удалось сделать ячейку")
            return }
        filterDelegate?.chooseFilter =  FiltersForTrackCollection(rawValue: cell.categoryTitleLabel.text ?? "Трекеры на сегодня") ?? .trackForActualDate
        tableView.reloadData()
        actionWithFilterDelegate?.filterDidUpdate()
        
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}

