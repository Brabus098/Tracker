//  ChooseTrackController.swift

import UIKit

final class ChooseTrackController: UIViewController{
    var parentTrackerVC: TrackersViewControllerProtocol?

    private lazy var ruttineButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addAction(UIAction(handler: { _ in

            let newController = CreateRegularTrackController()
            
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

            let unRegularController = UnRegularController()

            unRegularController.onDataCreated = { [weak self] newArray in
                self?.parentTrackerVC?.updateCategoriesArray(new: newArray)
            }
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
    
    private func findParentTrackerViewController() -> TrackersViewController {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? TrackersViewController {
                return viewController
            }
        }
        fatalError("TrackersViewController not found in responder chain")
    }
    
    private func setupNavController(){
        navigationController?.navigationItem.leftBarButtonItem = nil
        view.backgroundColor = .white
        // 1. Скрываем стандартный заголовок
        navigationItem.title = ""

        // 2. Создаем контейнер
        let titleContainer = UIView()
        navigationItem.titleView = titleContainer

        // 3. Добавляем кастомный лейбл
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 17)
        titleLabel.text = "Создание трекера"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(titleLabel)

        // 4. Устанавливаем констрейнты
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
