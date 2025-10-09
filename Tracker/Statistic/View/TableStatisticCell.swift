import UIKit

final class TableStatisticCell: UITableViewCell {
    
    private lazy var scoreLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        label.textAlignment = .left
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var goalLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        label.textAlignment = .left
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var container = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var gradientLayer: CAGradientLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
 
        container.layoutIfNeeded()
        
        if gradientLayer == nil {
            addGradientBorder()
        } else {
            gradientLayer?.frame = container.bounds
            if let shapeLayer = gradientLayer?.mask as? CAShapeLayer {
                shapeLayer.path = UIBezierPath(roundedRect: container.bounds, cornerRadius: 16).cgPath
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraint()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addGradientBorder() {
        guard container.bounds.width > 0 else { return } 
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = container.bounds
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: container.bounds, cornerRadius: 16).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = nil
        
        gradient.mask = shape
        container.layer.addSublayer(gradient)
        
        gradientLayer = gradient
        
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = UIColor.white.cgColor
        backgroundLayer.frame = container.bounds.insetBy(dx: 2, dy: 2)
        backgroundLayer.cornerRadius = 14
        backgroundLayer.masksToBounds = true
        container.layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    private func setupConstraint(){
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            scoreLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            scoreLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            scoreLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            goalLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 7),
            goalLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            goalLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            goalLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
    }
    
    func setupCell(text:String, score:String) {
        goalLabel.text = text
        scoreLabel.text = score
    }
}


