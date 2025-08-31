//  OnBoardController.swift

import UIKit
import Foundation

final class UniversalOnBoardController: UIViewController {
    
    private let backImageName: String
    private let mainLabelTitle: String
    private let currentPageOfPageControl: Int
    
    private lazy var backGroundImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: backImageName)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction(handler: { _ in
            self.switchToTabBarController()        }), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.text = mainLabelTitle
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .blackDay
        label.font = UIFont(name: "SFPro-Bold", size: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 2
        control.currentPage = currentPageOfPageControl
        control.currentPageIndicatorTintColor = .blackDay
        control.pageIndicatorTintColor = .backDayGrey
        control.translatesAutoresizingMaskIntoConstraints = false
        
        return control
    }()
    
    init(backImageName: String, mainLabelTitle: String, currentPageOfPageControl: Int) {
        self.backImageName = backImageName
        self.mainLabelTitle = mainLabelTitle
        self.currentPageOfPageControl = currentPageOfPageControl
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addElementAtView()
    }
    
    private func addElementAtView(){
        view.addSubview(backGroundImage)
        view.addSubview(button)
        view.addSubview(mainLabel)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            backGroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backGroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backGroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backGroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -130)
        ])
    }
    
    // Метод стирает предыдущие экраны и устанавливает корневой
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let rootController = TabBarController()

        window.rootViewController = rootController
    }
}
// TODO: Сохранить состояние изменненого рутового контроллера можно либо загрузь в кор дату либо юзердефолтс
