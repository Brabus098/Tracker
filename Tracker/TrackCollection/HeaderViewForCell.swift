//  HaderViewForCell.swift

import UIKit

final class HeaderViewForCell: UICollectionReusableView {
    private let headerTitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeaderTitleLabel()
        setupConstraint()
    }
    
    private func setupHeaderTitleLabel(){
        addSubItem(view: headerTitleLabel)
        headerTitleLabel.font = UIFont(name: "SFPro-Bold", size: 19)
    }
    
    private func setupConstraint(){
        NSLayoutConstraint.activate([
            headerTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 34),
            headerTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HeaderViewForCell{
    private func addSubItem(view: UIView){
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(header text: String){
        headerTitleLabel.text = text
    }
}
