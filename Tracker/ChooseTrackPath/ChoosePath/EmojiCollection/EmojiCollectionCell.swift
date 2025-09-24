import UIKit

final class EmojiCollectionCell: UICollectionViewCell {
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .clear
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiButton: UIButton = {
        let button = UIButton()
        
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(backView)
        contentView.addSubview(emojiButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backView.heightAnchor.constraint(equalToConstant: 52),
            backView.widthAnchor.constraint(equalToConstant: 52),
            
            emojiButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiButton.heightAnchor.constraint(equalToConstant: 32),
            emojiButton.widthAnchor.constraint(equalToConstant: 38)
        ])
    }
}

extension EmojiCollectionCell {
    
    func configurateCell(emoji: String) {
        emojiButton.setTitle(emoji, for: .normal)
        emojiButton.titleLabel?.font = UIFont(name: "SFPro-Bold", size: 32)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
