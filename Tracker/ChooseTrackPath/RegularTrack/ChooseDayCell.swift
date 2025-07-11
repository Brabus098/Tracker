//  ChooseDayCell.swift

import UIKit

final class ChooseDayCell: UITableViewCell { // ячейка таблицы где есть switch напротив дня недели
    
    private let switcher = UISwitch()
    private var dayLabel = UILabel()
    var switcherChangedHandler: ((Bool) -> Void)? // замыкание для фиксирования состояния switch в ячейке
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSwitcher()
        setupDayLabel()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSwitcher(){
        switcher.isOn = false
        contentView.addSubview(switcher)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc private func valueChanged(_ sender: UISwitch){
        switcherChangedHandler?(sender.isOn)
    }
    
    private func setupDayLabel(){
        dayLabel.font = UIFont(name: "SFPro-Regular", size: 17)
        contentView.addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureConstraints(){
        NSLayoutConstraint.activate([
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switcher.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            switcher.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),
            
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 31),
            dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -31)
        ])
    }
}

extension ChooseDayCell {
    func configurationCell(day: String){
        dayLabel.text = day
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        switcher.isOn = false
        switcherChangedHandler = nil
        dayLabel.text = nil
    }
}
