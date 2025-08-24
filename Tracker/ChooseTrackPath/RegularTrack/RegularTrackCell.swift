//  RegularTrackCell.swift

import UIKit

final class RegularTrackCell: UITableViewCell {

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private let cateGoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        label.textColor = UIColor.blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowButton")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        label.textColor = UIColor.systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(cateGoryLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(arrowImageView)

        topConstraint = cateGoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26)
        topConstraint?.isActive = true
        bottomConstraint = cateGoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26)
        bottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
    
            cateGoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            cateGoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -8),
           
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
            arrowImageView.heightAnchor.constraint(equalToConstant: 24),

            descriptionLabel.topAnchor.constraint(equalTo: cateGoryLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: cateGoryLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)

        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cateGoryLabel.text = nil
        descriptionLabel.text = nil
    }

    func configurateText(ForLabel: String) {
        cateGoryLabel.text = ForLabel
    }

    func configurateWith(newData label: [String], updateWeekDays: Bool ) {
        topConstraint?.isActive = false
        topConstraint = cateGoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15)
        topConstraint?.isActive = true
        
        bottomConstraint?.isActive = false
        bottomConstraint = cateGoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -38)
        bottomConstraint?.isActive = true
        
        if label.count == 7 {
            descriptionLabel.text = "Каждый день"
            
        } else {
            descriptionLabel.text = label.joined(separator: ", ")
        }
    }
}
