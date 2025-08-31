//  OnboardingViewController.swift

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private lazy var controllers: [UIViewController] = {
        
        let firstController = UniversalOnBoardController(backImageName: "FirstOnBoard",
                                                         mainLabelTitle: "Отслеживайте только то, что хотите", currentPageOfPageControl: 0)
        
        let secondController = UniversalOnBoardController(backImageName: "SecondBoard", mainLabelTitle: "Даже если это не литры воды и йога", currentPageOfPageControl: 1)
        
        return [firstController, secondController]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let first = controllers.first{
            setViewControllers([first], direction: .forward, animated: true)
        }
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

