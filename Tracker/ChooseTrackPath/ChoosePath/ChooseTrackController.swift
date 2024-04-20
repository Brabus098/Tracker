//  ChooseTrackController.swift

import UIKit

final class ChooseTrackController: UIViewController{
    weak var parentTrackerVC: TrackersViewControllerProtocol? // возможно больше не требуется
    var store: TrackerCategoryStore
    var dateOfTrackCreated: String
    
    private lazy var ruttineButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addAction(UIAction(handler: { _ in
            
            let emojiCollection = EmojiCollection()
            let colorCollection = ColorCollection()
            let trackModel = RegularTrackModel()
            let trackViewModel = TrackViewModel(for: trackModel)
            
            let newController = CreateRegularTrackController(emojiCollection: emojiCollection, colorCollection: colorCollection)
            
            newController.initialize(viewModel: trackViewModel)
            
            newController.onDataCreated = { [weak self] newArray in
                self?.parentTrackerVC?.updateCategoriesArray(new: newArray)
            }
            self.navigationController?.pushViewController(newController, animated: true)
        }), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var unregularButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Нерегулярное действие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.addAction(UIAction(handler: { _ in
            
            let emojiCollection = EmojiCollection()
            let colorCollection = ColorCollection()
            
            let unRegularController = UnRegularController(emojiCollection: emojiCollection, colorCollection: colorCollection, curentDate: self.dateOfTrackCreated, trackerCategoryStore: self.store)
            
            let trackModel = RegularTrackModel()
            let trackViewModel = TrackViewModel(for: trackModel)
            
            
            unRegularController.initialize(viewModel: trackViewModel)
            unRegularController.trackDelegate = self.parentTrackerVC as? any TrackCollectionActionDelegate
        
            self.navigationController?.pushViewController(unRegularController, animated: true)
        }), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavController()
        setupConstraint()
    }
    
    init(store: TrackerCategoryStore, dateOfTrackCreated: String) {
        self.store = store
        self.dateOfTrackCreated = dateOfTrackCreated
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupNavController(){
        navigationController?.navigationItem.leftBarButtonItem = nil
        view.backgroundColor = .white
        navigationItem.title = ""
        
        let titleContainer = UIView()
        navigationItem.titleView = titleContainer
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 17)
        titleLabel.text = "Создание трекера"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 25)
        ])
    }
    
    private func setupConstraint(){
        NSLayoutConstraint.activate([
            
            ruttineButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ruttineButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ruttineButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 281),
            ruttineButton.heightAnchor.constraint(equalToConstant: 60),
            
            unregularButton.leadingAnchor.constraint(equalTo: ruttineButton.leadingAnchor),
            unregularButton.trailingAnchor.constraint(equalTo: ruttineButton.trailingAnchor),
            unregularButton.topAnchor.constraint(equalTo: ruttineButton.bottomAnchor, constant: 16),
            unregularButton.heightAnchor.constraint(equalTo: ruttineButton.heightAnchor)
        ])
    }
}
