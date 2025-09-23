//  BlurView.swift

import UIKit

final class BlurView: UIView {
    
    private var blurEffectView: UIVisualEffectView!
    
    var holeRect: CGRect = .zero {
        didSet { updateMask() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurEffectView.frame = bounds
        updateMask()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlur()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    // Метод настраивает блюр
    private func setupBlur() {
        let blurEffect = UIBlurEffect(style: .regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        backgroundColor = .clear
        alpha = 1.0
        tag = 1001
    }
    // Метод добавляет "рамку" в блюр
    private func updateMask() {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: bounds)
        
        // Добавляем отверстие
        let holePath = UIBezierPath(roundedRect: holeRect, cornerRadius: 16)
        path.append(holePath)
        path.usesEvenOddFillRule = true
        
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        layer.mask = maskLayer
    }
}
