//  RegularTrackCell.swift

import UIKit

final class RegularTrackCell: UITableViewCell { // ячейка таблицы где указываются сокращенные дни недели
    
    private let cateGoryLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    // Констрейнты для изменения отступовв при добавление дней и категории
    private var categoryLabelTopAnchor: NSLayoutConstraint?
    private var categoryLabelBottomAnchor: NSLayoutConstraint?
    
    private lazy var descriptionLabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        label.textColor = UIColor.systemGray
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupElements() {
        cateGoryLabel.font = UIFont(name: "SFPro-Regular", size: 17)
        cateGoryLabel.textColor = UIColor.blackDay
        contentView.addSubview(cateGoryLabel)
        cateGoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        arrowImageView.image = UIImage(named: "arrowButton")
        contentView.addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabelTopAnchor = cateGoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26)
        categoryLabelBottomAnchor = cateGoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -27)
        
        guard let categoryLabelTopAnchor, let categoryLabelBottomAnchor else { return }
        
        NSLayoutConstraint.activate([
            cateGoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabelTopAnchor,
            categoryLabelBottomAnchor,
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
            arrowImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -27)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cateGoryLabel.text = nil
    }
}

// Config methods
extension RegularTrackCell {
    // Метод задает имя ячейки вызывается из createRegularTrackController
    func configurateText(ForLabel: String) {
        cateGoryLabel.text = ForLabel
    }
    
    func configurateWith(newData label: [String], updateWeekDays: Bool ){
        
        setNew(label: label)
        
        checkConstraint(top: categoryLabelTopAnchor, bottom: categoryLabelBottomAnchor, mode: false)
        
        categoryLabelTopAnchor =  cateGoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15)
        categoryLabelBottomAnchor =  cateGoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -41)
        
        checkConstraint(top: categoryLabelTopAnchor, bottom: categoryLabelBottomAnchor, mode: true)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: cateGoryLabel.bottomAnchor, constant: 2),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            descriptionLabel.leadingAnchor.constraint(equalTo: cateGoryLabel.leadingAnchor)
        ])
        
        self.contentView.layoutIfNeeded()
    }
}

extension RegularTrackCell {
    
    // метод задает сокращенный формат выбранных дней недели - "пн"
    private func setNew(label: [String]){
        
        if label.count == 7 {
            descriptionLabel.text = "Каждый день"
        } else {
            // Создаем новый текст из массива
            let newText = label.joined(separator: ", ")
            descriptionLabel.text = newText
        }
    }
    
    // Метод обновляет констрейнты в зависимости от состояния
    private func checkConstraint(top: NSLayoutConstraint?, bottom: NSLayoutConstraint?, mode: Bool) {
        if let top, let bottom {
            if mode {
                NSLayoutConstraint.activate([
                    top,
                    bottom
                ])
            } else {
                NSLayoutConstraint.deactivate([
                    top,
                    bottom
                ])
            }
        }
    }
}
