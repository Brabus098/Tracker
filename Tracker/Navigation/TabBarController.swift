//  TabBarController.swift

import UIKit

final class TabBarController: UITabBarController {
    let trackCollection = TrackCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBar()
    }
    
    private func setupTabs(){
        let trackController = TrackersViewController(track: trackCollection)
        let trackNavigationController = PlusNavigationController(rootViewController: trackController)

        trackController.tabBarItem = UITabBarItem(title: "Трекеры",
                                                  image: UIImage(named: "tracTabBarLogo"),
                                                  tag: 0)
        
        let statisticController = StatisticController()
        statisticController.tabBarItem = UITabBarItem(title: "Статистика",
                                                      image: UIImage(named: "statisticTabBarLogo"),
                                                      tag: 1)
      
        
        self.setViewControllers([trackNavigationController, statisticController], animated: true)
    }
    
    private func setupTabBar(){
        self.tabBar.layer.masksToBounds = true
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}
