//  UnRegularController.swift

import UIKit

final class UnRegularController: UIViewController {
    
    // Замыкание, принимающее данные (TrackerCategory)
    var onDataCreated: (([TrackerCategory]) -> Void)?
    
    // MARK: Properties
    private let table = UITableView()
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private var textFieldView: CustomTextFieldProtocol?
    
    // MARK: DataBase properties
    private var dataBase = ["Категория"]
    private var categoryTitle = String() // для сохранения названия категории
    var titleOfTrack = "" // для сохранения названия трека
    
    // MARK: ViewModel
    private var viewModel: TrackViewModel?
    private var titleCategoryState: IndexPath? // хранит состояние выбранной категории
    
    // MARK: Collections
    private var emojiCollection: EmojiCollectionProtocol?
    private var colorCollection: ColorCollectionProtocol?
    
    private lazy var cancelButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }()
    
    private lazy var saveButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.backgroundColor = UIColor.grey.cgColor
        
        button.addAction(UIAction(handler: { [weak self] _ in
            
            //            guard let timeRepeate = self?.timeForRepeat, let mainTitle = self?.categoryTitle, let trackTitle = self?.titleOfTrack  else { return }
            //            self?.viewModel?.addTrackWith(titleOfCategory: mainTitle, titleOfTrack: trackTitle, timeTable: timeRepeate, emojiCol: self?.emojiCollection ?? EmojiCollection(), colorCol: self?.colorCollection ?? ColorCollection()) // Оправляем данные во вью модель
            
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }()
    
    private lazy var restrictionCount = {
        var label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        
        return label
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setupKeyboard()
    }
    
    init(emojiCollection: EmojiCollectionProtocol, colorCollection: ColorCollectionProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.emojiCollection = emojiCollection
        self.colorCollection = colorCollection
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize(viewModel: TrackViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.titleOfTrack = { [weak self] newTitle in self?.updateTitle(title: newTitle)
        }
        
        viewModel.limitLabel = { [weak self] limitState in
            self?.updateLayout(showLimit: limitState)
        }
        
        // Обновление ячейки таблицы
        viewModel.titleOfCategory = { [weak self] actualTitle in
            self?.categoryTitle = actualTitle
            self?.updateCategoriesCell(categoryArray: actualTitle)
        }
        
        viewModel.indexPathChooseTitle = {[weak self] newState in
            self?.titleCategoryState = newState // состояние ячейки выбранного элемента на экране категории
        }
    }
    
    // MARK: Methods
    private func configureViews(){
        view.backgroundColor = .white
        setupNavigationTitle()
        setupTable()
        setupCollections()
        textFieldView = TextFieldView(viewModel: viewModel ?? TrackViewModel(for: RegularTrackModel()))
        scrollAddStack()
        addItemAtScroll()
    }
    
    private func setupNavigationTitle(){
        navigationItem.title = ""
        
        let titleContainer = UIView()
        navigationItem.titleView = titleContainer
        let titleLabel = UILabel()
        
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 17)
        titleLabel.text = "Новое регулярное событие"
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 20)
        ])
        
        navigationItem.hidesBackButton = true
    }
    
    private func setupCollections() {
        guard let emojiCollection, let colorCollection else { return }
        
        emojiCollection.configurateEmojiCollection()
        colorCollection.configColorCollection()
        
        let emojiC = emojiCollection.emojiCollection
        let colorC = colorCollection.colorCollection
        
        emojiC.isScrollEnabled = false
        colorC.isScrollEnabled = false
        
        emojiC.translatesAutoresizingMaskIntoConstraints = false
        colorC.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Дебаг-рамки
        //        emojiC.layer.borderWidth = 2
        //        emojiC.layer.borderColor = UIColor.red.cgColor
        //        colorC.layer.borderWidth = 2
        //        colorC.layer.borderColor = UIColor.green.cgColor
        
        NSLayoutConstraint.activate([
            emojiC.heightAnchor.constraint(equalToConstant: 210),
            colorC.heightAnchor.constraint(equalToConstant: 210)
        ])
    }
    
    private func setupTable(){
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false
        table.separatorStyle = .none
        //                //Временно:
        //                table.layer.borderWidth = 2
        //                table.layer.borderColor = UIColor.purple.cgColor
        
        table.isUserInteractionEnabled = true
        table.dataSource = self
        table.delegate = self
        table.register(RegularTrackCell.self, forCellReuseIdentifier: "RegularTrackCell")
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.rowHeight = 75
        // Динамическая высота таблицы
        let tableHeight = CGFloat(dataBase.count) * table.rowHeight
        table.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
    }
    
    // Метод обновленеия визуальной составялющей ячейки
    private func updateCategoriesCell(categoryArray:String){
        table.visibleCells.forEach { cell in
            guard let customCell = cell as? RegularTrackCell,
                  let indexPath = table.indexPath(for: customCell),
                  dataBase[indexPath.row].prefix(9) == "Категория" else { return }
            
            customCell.configurateWith(newData: categoryArray)
        }
    }
}

// MARK: Setup TableView
extension UnRegularController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataBase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RegularTrackCell", for: indexPath) as? RegularTrackCell else { return UITableViewCell()}
        
        cell.configurateText(ForLabel: dataBase[indexPath.row])
        cell.backgroundColor = UIColor(named: "BackgroundDay")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if dataBase[indexPath.row] == "Категория" {
            guard let viewModel else { return }
            
            let createCategoryVC = AddNewCategoryController(transitionNewCategoryTitleToViewModel: viewModel, selectedIndexPath: titleCategoryState ?? nil)
            
            let createCategoryVM = CreateCategoryViewModel(model: CreateCategoryModel())
            createCategoryVC.initialize(viewModel: createCategoryVM)
            
            navigationController?.pushViewController(createCategoryVC, animated: true)
            
        }
    }
}

// MARK: Methods calls trackViewModel
extension UnRegularController: TextFieldControllerProtocol {
    
    // метод обновляет название трека - реагирует на байдинг titleOfTrack
    func updateTitle(title: String){
        titleOfTrack = title
        if !title.isEmpty {
            saveButton.layer.backgroundColor = UIColor.blackDay.cgColor
            saveButton.isEnabled = true
        } else {
            saveButton.layer.backgroundColor = UIColor.grey.cgColor
            saveButton.isEnabled = false
        }
    }
    
    // Метод обновляет высоту строк при показе ограничителя - реагирует на байдинг limitLabel
    func updateLayout(showLimit: Bool) {
        guard let textFieldView else { return }
        
        restrictionCount.isHidden = !showLimit
        UIView.animate(withDuration: 0.3) {
            self.stackView.setCustomSpacing(showLimit ? 8 : 24, after: textFieldView)
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: Setup scroll and stack views
extension UnRegularController {
    
    private func scrollAddStack(){
        
        // Stack
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        //Scroll
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),// длинна скролла
            
            // StackView внутри ScrollView
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32) // Ширина с учетом отступов
        ])
    }
    
    private func addItemAtScroll(){
        guard let textFieldView else { return }
        
        let buttonStack = createButtonStack()
        
        stackView.addArrangedSubview(textFieldView)
        stackView.addArrangedSubview(restrictionCount)
        stackView.addArrangedSubview(table)
        stackView.addArrangedSubview(emojiCollection?.emojiCollection ?? UICollectionView())
        stackView.addArrangedSubview(colorCollection?.colorCollection ?? UICollectionView())
        stackView.addArrangedSubview(buttonStack)
        
        restrictionCount.isHidden = true
    }
    
    private func createButtonStack() -> UIStackView{
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .center
        buttonStack.spacing = 8
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(saveButton)
        return buttonStack
    }
}

// Keyboard methods
extension UnRegularController {
    private func setupKeyboard(){
        let tapCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        tapCloseKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapCloseKeyboard)
    }
    
    @objc private func closeKeyBoard(){
        view.endEditing(true)
        textFieldView?.updateTitleWhenCloseTheKeyboard()
    }
}

//TODO: ПЕРЕНОС ОСТАТКОВ байндингов КОЛЛЕКЦИИ + сохранение трека + логика отображения 
