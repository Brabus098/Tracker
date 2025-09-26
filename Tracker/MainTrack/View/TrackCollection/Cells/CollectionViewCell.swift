//  CollectionViewCell.swift

import UIKit
final class CollectionViewCell: UICollectionViewCell {
    
    // Свойства для ячейки
    private let goalLabel =  UILabel()
    private let backView = UIView()
    private let emojiBackColor = UIView()
    private let countSuccessLabel = UILabel()
    private let emojiLabel = UILabel()
    private let plusDayButton = UIButton()
    private var buttonState: ButtonState = .normal
    
    // Свойства для передачи информации контроллеру
    private var indexPath: IndexPath?
    private var trackerId: UInt?
    weak var delegate: TrackerCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBackView()
        setupGoalLabel()
        setupCountSuccessLabel()
        setupEmojiBackground()
        setupEmojiLabel()
        setupButton()
        setupConstraint() // всегда последняя
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getActuaLabel() -> String {
        if let label = goalLabel.text {
            return label
        } else { return "" }
    }
    
    private func setupBackView(){
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        addSubItem(view: backView)
        addLayers(for: backView, layer: 16)
    }
    
    private func setupEmojiLabel(){
        addSubItem(view: emojiLabel)
        
        countSuccessLabel.text = "0 дней" // Количество выполненных дней
        
        plusDayButton.backgroundColor = .white
        backView.backgroundColor = .purple
    }
    
    private func setupButton(){
        addSubItem(view: plusDayButton)
        setActualBackColorForImage()
        addLayers(for: plusDayButton, layer: 34/2)
        plusDayButton.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func setActualBackColorForImage(){
        
        let image = UIImage(named: "AddButton")?
            .withTintColor(backView.backgroundColor ?? .red, renderingMode: .alwaysOriginal)
        
        let imageForSelected = UIImage(named: "AddedButton")?
            .withTintColor(backView.backgroundColor ?? .red, renderingMode: .alwaysOriginal)
        
        plusDayButton.setImage(image, for: .normal)
        plusDayButton.setImage(imageForSelected, for: .selected)
    }
    
    @objc private func plusButtonTapped(_ sender: UIButton) {
        guard let trackerId = trackerId else { return }
        delegate?.didTapPlusButton(for: trackerId) // оповещаем коллекцию, о том что кнопка нажата
    }
    
    private func setupGoalLabel(){
        addSubItem(view: goalLabel)
        goalLabel.textColor = .white
        goalLabel.font = UIFont(name: "SFPro-Medium", size: 12)
        goalLabel.numberOfLines = 2
    }
    
    private func setupEmojiBackground(){
        addSubItem(view: emojiBackColor)
        emojiBackColor.backgroundColor = .emogiBack
        addLayers(for: emojiBackColor, layer: 27 / 2)
    }
    
    private func setupCountSuccessLabel(){
        addSubItem(view: countSuccessLabel)
        countSuccessLabel.textColor = .black
        countSuccessLabel.font = UIFont(name: "SFPro-Medium", size: 12)
    }
    
    private func setupConstraint(){
        
        NSLayoutConstraint.activate([
            
            // Настройка заднего фона
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.61),
            
            // Настройка лейбла с целью
            goalLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -12),
            goalLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -12),
            goalLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12),
            goalLabel.heightAnchor.constraint(equalToConstant: 34),
            
            // Настройка emojiBack
            emojiBackColor.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiBackColor.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackColor.heightAnchor.constraint(equalToConstant: 27),
            emojiBackColor.widthAnchor.constraint(equalToConstant: 27),
            
            // Настройка emojilabel
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackColor.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackColor.centerYAnchor),
            
            // Настройка лейбла с количестовом выполненых дней
            countSuccessLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countSuccessLabel.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 16),
            countSuccessLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            plusDayButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusDayButton.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 8),
            plusDayButton.heightAnchor.constraint(equalToConstant: 34),
            plusDayButton.widthAnchor.constraint(equalToConstant: 34),
            plusDayButton.centerXAnchor.constraint(equalTo: countSuccessLabel.centerXAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Сбросить данные
        goalLabel.text = nil
        countSuccessLabel.text = nil
        indexPath = nil
        trackerId = nil
        buttonState = .normal
    }
}

extension CollectionViewCell {
    
    func configurateCell(goalText: String,  indexPath: IndexPath, trackerId: Int16, counter: Int32, button: ButtonState, emoji: String, color: UIColor){
        
        buttonState = button
        goalLabel.text = goalText
        emojiLabel.text = emoji
        emojiLabel.font = UIFont(name: "SFPro-Bold", size: 16)
        backView.backgroundColor = color
        
        setActualBackColorForImage()
        
        let ending = Int(counter)
        let localizedString = String.localizedStringWithFormat(
            NSLocalizedString("ending", comment: ""),
            ending
        )
        countSuccessLabel.text = localizedString
        self.indexPath = indexPath
        self.trackerId = UInt(trackerId)
        
        // Устанавливаем состояние кнопки в зависимости от buttonState
        switch buttonState {
        case .normal:
            plusDayButton.isSelected = false
            plusDayButton.isEnabled = true
        case .selected:
            plusDayButton.isSelected = true
            plusDayButton.isEnabled = true
        case .unActive:
            plusDayButton.isSelected = false
            plusDayButton.isEnabled = false
        }
    }
}

extension CollectionViewCell{
    
    private func addSubItem(view: UIView){
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addLayers(for view: UIView, layer cornerRadius: Float){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
    }
}
