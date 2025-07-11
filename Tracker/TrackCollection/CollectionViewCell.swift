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
    
    // Mock
    private let emojiArray = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
    private let colorArray: [UIColor] = [UIColor.blue, UIColor.purple, UIColor.green]
    
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
        setupConstraint() // MARK: всегда последняя
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBackView(){
        addSubItem(view: backView)
        addLayers(for: backView, layer: 16)
    }
    
    // метод генерит рандомные значения для Emoji и цветов
    private func setupEmojiLabel(){
        addSubItem(view: emojiLabel)
        
        emojiLabel.text = emojiArray.randomElement()
        countSuccessLabel.text = "0 дней" // Количество выполненных дней
        let randomColor = colorArray.randomElement()
        
        plusDayButton.backgroundColor = .white
        backView.backgroundColor = randomColor
    }
    
    private func setupButton(){
        addSubItem(view: plusDayButton)
        
        let image = UIImage(named: "AddButton")?
            .withTintColor(backView.backgroundColor ?? .red, renderingMode: .alwaysOriginal)
        let imageForSelected = UIImage(named: "AddedButton")?
            .withTintColor(backView.backgroundColor ?? .red, renderingMode: .alwaysOriginal)
        
        plusDayButton.setImage(image, for: .normal)
        addLayers(for: plusDayButton, layer: 34/2)
        plusDayButton.setImage(imageForSelected, for: .selected)
        
        plusDayButton.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
        
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
        addLayers(for: emojiBackColor, layer: 24 / 2)
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
            
            // Настройка emoji
            emojiBackColor.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiBackColor.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackColor.heightAnchor.constraint(equalToConstant: 24),
            emojiBackColor.widthAnchor.constraint(equalToConstant: 24),
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
    
    func configurateCell(goalText: String,  indexPath: IndexPath, trackerId: UInt, counter: Int, button: ButtonState){
        
        buttonState = button
        goalLabel.text = goalText // Цель трека
        let ending = findThe(ending: counter)
        countSuccessLabel.text = String(counter) + " " + ending // Количество успешных дней
        self.indexPath = indexPath
        self.trackerId = trackerId
        
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

extension CollectionViewCell {
    // метод опеределяет правильное окнончание для countSuccessLabel в ячейке
    private func findThe(ending countLabel: Int) -> String{
        
        let lastTwoDigits = abs(countLabel) % 100
        let lastDigit = abs(countLabel) % 10
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "дней"
        }
        
        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
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
