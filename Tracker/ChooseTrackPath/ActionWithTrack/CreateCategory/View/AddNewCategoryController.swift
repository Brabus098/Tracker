//  CreateNewCategory.swift

import UIKit

final class AddNewCategoryController: UIViewController {
    
    // Table
    private let tableView = UITableView()
    private var selectedCell: UITableViewCell?
    private var selectedIndexPath: IndexPath?
    
    // Menu + Blur
    private var menuView: MenuView?
    private var customBlurView: BlurView?
    
    private let noCategoryImageView = UIImageView()
    private lazy var createNewCategoryButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.addAction(UIAction(handler: { [weak self] _ in
            guard let viewModel = self?.viewModel else { return }
            
            let createCategoryController = CreateCategoryController()
            createCategoryController.initialize(viewModel: viewModel)
            self?.navigationController?.pushViewController(createCategoryController, animated: true)
        }), for: .touchUpInside)
        
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var questionLabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу?"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    // View Models
    private var viewModel: CreateCategoryViewModel? // для передачи сохраненой категории
    private var transitionNewCategoryTitleToViewModel: TrackViewModel? // вьюмодель переданная при старте
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupImageView()
        setupConstraint()
        setupTableView()
        setupLongPressGesture()
    }
    
    init(transitionNewCategoryTitleToViewModel: TrackViewModel, selectedIndexPath: IndexPath?) {
        super.init(nibName: nil, bundle: nil)
        
        self.selectedIndexPath = selectedIndexPath
        self.transitionNewCategoryTitleToViewModel = transitionNewCategoryTitleToViewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize(viewModel: CreateCategoryViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    func bind(){
        viewModel?.actualTitleUpdate = { [weak self] _ in
            // добавление новых категорий
            self?.tableView.reloadData()
        }
        
        viewModel?.actualDataSourceCounter = { [weak self] count in
            self?.tableView.isHidden = count == 0
            
            //            if count == 0 {
            //                self?.tableView.isHidden = true
            //            } else {
            //                self?.tableView.isHidden = false
            //            }
        }
    }
    
    private func setupImageView(){
        view.addSubview(noCategoryImageView)
        noCategoryImageView.translatesAutoresizingMaskIntoConstraints = false
        noCategoryImageView.contentMode = .scaleAspectFit
        noCategoryImageView.image = UIImage(named: "noTrackImageLogo")
    }
    
    private func setupNavigationTitle(){
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        navigationItem.title = ""
        
        let titleContainerView = UIView()
        navigationItem.titleView = titleContainerView
        let label = UILabel()
        
        label.text = "Категория"
        label.font = UIFont(name: "SFPro-Medium", size: 17)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: titleContainerView.centerXAnchor)
        ])
    }
    
    private func setupConstraint(){
        
        NSLayoutConstraint.activate([
            
            // Central image
            noCategoryImageView.widthAnchor.constraint(equalToConstant: 80),
            noCategoryImageView.heightAnchor.constraint(equalToConstant: 80),
            noCategoryImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noCategoryImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -100),
            
            
            // Label after image
            questionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            questionLabel.topAnchor.constraint(equalTo: noCategoryImageView.bottomAnchor, constant: 8),
            
            // Create Button
            createNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createNewCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createNewCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension AddNewCategoryController: UITableViewDataSource {
    
    func setupTableView(){
        viewModel?.actualValueFromArray()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            tableView.bottomAnchor.constraint(equalTo: createNewCategoryButton.bottomAnchor, constant: -70),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.actualTitleArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        if let dataSource = viewModel?.actualTitleArray {
            cell.configuration(title: dataSource[indexPath.row])
        }
        
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        cell.setSeparatorHidden(indexPath.row == totalRows - 1) // убираем у последней строки
        
        // Заполняем ячейку выбранной категории если она передавалась
        if let selectedIndexPath, selectedIndexPath == indexPath {
            cell.imageIs(hidden: false)
        }
        
        return cell
    }
}

extension AddNewCategoryController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 1. Снимаем выделение с предыдущей ячейки
        if let previousIndexPath = selectedIndexPath,
           let previousCell = tableView.cellForRow(at: previousIndexPath) as? CategoryCell {
            previousCell.imageIs(hidden: true) // Скрываем изображение у предыдущей
        }
        
        // 2. Обновляем текущую ячейку
        guard let currentCell = tableView.cellForRow(at: indexPath) as? CategoryCell else { return }
        currentCell.imageIs(hidden: false) // Показываем изображение у текущей
        
        // 3. Передаем вью модели новое название категории и новое состояние элементов категории
        if let chooseTitleTrack = currentCell.categoryTitleLabel.text {
            transitionNewCategoryTitleToViewModel?.updateCategory(name: chooseTitleTrack, state: indexPath)
            
        }
        self.navigationController?.popViewController(animated: true)
    }
}

// Custom menu + Blur
extension AddNewCategoryController {
    func setupLongPressGesture(){
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: tableView)
        
        switch gesture.state {
        case .began:
            guard let indexPath = tableView.indexPathForRow(at: location),
                  let cell = tableView.cellForRow(at: indexPath),
                  let specialCell = tableView.cellForRow(at: indexPath) as? CategoryCell else { return }
            
            selectedCell = cell
            var titleAtCell = specialCell.categoryTitleLabel.text
            addBlurEffect(excluding: cell)
            addCustomMenu(for: cell, title: titleAtCell)
            
            cell.backgroundColor = .backgroundDayTwo // поменяли цвет ячейки
            
        default:
            break
        }
    }
    
    private func addBlurEffect(excluding cell: UITableViewCell) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let blurView = BlurView(frame: window.bounds)
        
        // Получаем координаты ячейки относительно window
        let cellFrameInWindow = tableView.convert(cell.frame, to: window)
        blurView.holeRect = cellFrameInWindow
        
        // Добавляем жест на закрытие в свободной области
        let tapOutside = UITapGestureRecognizer(target: self, action: #selector (handleBackgroundTap(_:)))
        blurView.addGestureRecognizer(tapOutside)
        
        // Добавляем на window
        window.addSubview(blurView)
        
        blurView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            blurView.alpha = 1.0
        }
        
        self.customBlurView = blurView
    }
    
    @objc private func handleBackgroundTap(_ tap: UITapGestureRecognizer){
        let tapLocation = tap.location(in: menuView)
        if menuView?.bounds.contains(tapLocation) == false {
            removeBlurEffect()
        }
    }
    
    private func addCustomMenu(for cell: UITableViewCell, title: String?) {
        
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let menu = MenuView(tableDataBaseActions: ["Редактировать", "Удалить"], delegate: self, chooseCategoryTitle: title ?? " НЕТО")
        
        let cellFrameInWindow = tableView.convert(cell.frame, to: window)
        
        menu.translatesAutoresizingMaskIntoConstraints = true
        
        // Позиционируем меню
        let width: CGFloat = 250
        let height: CGFloat = 48 * 2
        
        menu.frame = CGRect(
            x: cellFrameInWindow.minX,
            y: cellFrameInWindow.maxY + 12,
            width: width,
            height: height
        )
        
        window.addSubview(menu)
        self.menuView = menu
    }
    
    private func removeBlurEffect() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.menuView?.alpha = 0
            self.customBlurView?.alpha = 0
        }) { _ in
            // Удаляем из superview после анимации
            self.menuView?.removeFromSuperview()
            self.customBlurView?.removeFromSuperview()
            
            // Обнуляем переменные
            self.menuView = nil
            self.customBlurView = nil
            
            // Восстанавливаем цвет ячейки
            self.selectedCell?.backgroundColor = .clear
        }
    }
}

extension AddNewCategoryController: CustomMenuDelegate {
    
    func choose(action isWas: MenuActions, chooseTitle: String){
        switch isWas {
        case .delete:
            presentAlertWithTitle(text: "Эта категория точно не нужна?", TrackNameToDelete: chooseTitle)
        case .edit:
            let changeController = EditCategoryTitleController(viewModel: viewModel, titleForEdit: chooseTitle)
            navigationController?.pushViewController(changeController, animated: true)
            removeBlurEffect()
        case .unFix, .fix: removeBlurEffect()
        }
    }
    
    private func presentAlertWithTitle(text: String, TrackNameToDelete: String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: {[weak self] _ in
            self?.viewModel?.remove(title: TrackNameToDelete)
            self?.removeBlurEffect()
        }))
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel,
                                      handler: {[weak self] _ in
            self?.removeBlurEffect()
        }))
        
        present(alert, animated: true)
    }
}
