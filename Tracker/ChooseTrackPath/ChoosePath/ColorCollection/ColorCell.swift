//  ColorCell.swift

import UIKit

final class ColorCell: UICollectionViewCell {
    
    private lazy var colorButton = {
        let button = UIButton()
        button.backgroundColor = .white
        
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(changeBackViewColor), for: .touchUpInside)
        return button
    }()
    
    private lazy var backView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var actualBorderColor = UIColor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constraintViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func changeBackViewColor(){
        backView.layer.borderColor = actualBorderColor.cgColor
        backView.layer.borderWidth = 3
    }
    
    private func constraintViews(){
        
        NSLayoutConstraint.activate([
            colorButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorButton.heightAnchor.constraint(equalToConstant: 40),
            colorButton.widthAnchor.constraint(equalToConstant: 40),
            
            backView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backView.heightAnchor.constraint(equalToConstant: 46),
            backView.widthAnchor.constraint(equalToConstant: 46)
        ])
    }
}

extension ColorCell {
    func configurateCell(color: UIColor){
        colorButton.backgroundColor = color
        actualBorderColor = color
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        colorButton.backgroundColor = nil
    }
}
