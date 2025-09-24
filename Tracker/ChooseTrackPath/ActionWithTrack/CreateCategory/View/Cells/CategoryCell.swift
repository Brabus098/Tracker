//  СategoryCell.swift

import UIKit

final class CategoryCell: UITableViewCell {
    
    private let separator = UIView()
    
    lazy var categoryTitleLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        label.textColor = UIColor.blackDay
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var successImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ChooseLogo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupElement()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupElement(){
        
        // Кастомный разделитель
        separator.backgroundColor = .backDayGrey
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .backgroundDay
        
        NSLayoutConstraint.activate([
            
            successImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            successImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            successImageView.widthAnchor.constraint(equalToConstant: 26),
            successImageView.heightAnchor.constraint(equalToConstant: 26),
            
            categoryTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 21),
            categoryTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -21),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
// MARK: Public methods for settings cell
extension CategoryCell {
    func configuration(title: String) { categoryTitleLabel.text = title }
    func imageIs(hidden status: Bool) { successImageView.isHidden = status }
    func setSeparatorHidden(_ hidden: Bool) { separator.isHidden = hidden }
}

extension CategoryCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryTitleLabel.text = nil
        successImageView.image = nil
    }
}
