//  TableStatisticController.swift

import UIKit

final class TableStatisticController: UITableViewController {
    
    private var data = ["Лучший период", "Идеальные дни", "Трекеров завершено", "Среднее значение"]
    var dataScore = [0,0,0,0] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(TableStatisticCell.self, forCellReuseIdentifier: "TableStatisticCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableStatisticCell", for: indexPath) as? TableStatisticCell else {return UITableViewCell()}
        
        cell.setupCell(text: data[indexPath.row], score: String(dataScore[indexPath.row]))
        
        return cell
    }
}
