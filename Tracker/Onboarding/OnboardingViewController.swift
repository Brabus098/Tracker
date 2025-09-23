//  OnboardingViewController.swift

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private lazy var controllers: [UIViewController] = {
        
        
        let firstController = UniversalOnBoardController(backImageName: "FirstOnBoard",
                                                         mainLabelTitle: "Отслеживайте только то, что хотите", currentPageOfPageControl: 0, userDefaultsDelegate: self.enterStatusDelegate ?? EnterSettingsUserDefaults())
        
        let secondController = UniversalOnBoardController(backImageName: "SecondBoard", mainLabelTitle: "Даже если это не литры воды и йога", currentPageOfPageControl: 1, userDefaultsDelegate: self.enterStatusDelegate ?? EnterSettingsUserDefaults() )
        
        return [firstController, secondController]
    }()
    
    var enterStatusDelegate: EnterSettingsUserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        checkFirstEnterStatus()
        if let first = controllers.first{
            setViewControllers([first], direction: .forward, animated: true)
        }
    }
    
    func checkFirstEnterStatus(){
        if let status = enterStatusDelegate?.enterStatus{
            self.switchToTabBarController()
        }
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

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //возвращаем предыдущий (относительно переданного viewController) дочерний контроллер
        guard let viewControllerIndex = controllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return controllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //возвращаем следующий (относительно переданного viewController) дочерний контроллер
        guard let viewControllerIndex = controllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < controllers.count else {
            return nil
        }
        
        return controllers[nextIndex]
    }
}

