//  CreateTracHeader.swift

import UIKit

final class CreateTrackHeader: UICollectionReusableView {
    
    private let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeaderLabel()
        headerLabelConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHeaderLabel(){
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func headerLabelConstraint(){
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor,  constant: -13),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 9),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
    }
}

extension CreateTrackHeader {
    func configHeader(title: String){
        headerLabel.text = title
        headerLabel.font = UIFont(name: "SFPro-Bold", size: 17) // должен быть 19
        headerLabel.textColor = .blackDay
    }
}
