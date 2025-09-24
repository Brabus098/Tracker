//  MenuCell.swift

import UIKit

final class MenuCell: UITableViewCell {
    
    private var label = UILabel()
    private let separator = UIView()
    private let separatorHeight: CGFloat = 1
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addLabel()
        applySeparatorMask()
        backgroundColor = .lightGrey
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applySeparatorMask()
    }
    
    private func applySeparatorMask() {
        // Создаем «окошко» для прозрачного разделителя
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: bounds)
        
        let holeRect = CGRect(
            x: 0,
            y: bounds.height - separatorHeight,
            width: bounds.width,
            height: separatorHeight
        )
        let holePath = UIBezierPath(rect: holeRect)
        
        path.append(holePath)
        path.usesEvenOddFillRule = true
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        layer.mask = maskLayer
    }
    
    private func addLabel(){
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
}
// Public methods
extension MenuCell {
    func configurationCell(text: String){ label.text = text }
    func changeLabelColor(){ label.textColor = .red }
}
