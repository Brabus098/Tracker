//  TabBarController.swift

import UIKit

final class TabBarController: UITabBarController {
    
    let storeReader = TrackerStoreReader()
    let color = Colors()
    let recordStore = TrackerRecordStore()
    lazy var trackCollection = TrackCollection(trackerStore: storeReader, recordStore: recordStore)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBar()
    }
    
    private func setupTabs(){
        
        let model = RegularTrackModel()
        let viewModel = TrackViewModel(for: model)
        let filterUD = FiltersUserDefaults()
        let trackController = TrackersViewController(track: trackCollection, viewModel: viewModel, filterUserDefaults: filterUD)
        let trackNavigationController = PlusNavigationController(rootViewController: trackController)
        
        trackController.tabBarItem = UITabBarItem(title: String(localized: "Trackers"),
                                                  image: UIImage(named: "tracTabBarLogo"),
                                                  tag: 0)
        
        let modelForStatisticVC = StatisticModel()
        let viewModelForStatisticVC = StatisticViewModel(model: modelForStatisticVC)
        let statisticController = StatisticController(viewModel: viewModelForStatisticVC)
        let navigationStatisticController = UINavigationController(rootViewController: statisticController)
        
        statisticController.tabBarItem = UITabBarItem(title: String(localized: "Statistics"),
                                                      image: UIImage(named: "statisticTabBarLogo"),
                                                      tag: 1)
        
        self.setViewControllers([trackNavigationController, navigationStatisticController], animated: true)
    }
    
    private func setupTabBar() {
        self.tabBar.layer.masksToBounds = true
        
        // Вместо layer.border используем отдельную view
        let borderView = UIView()
        borderView.backgroundColor = color.colorForSeparator
        borderView.translatesAutoresizingMaskIntoConstraints = false
        self.tabBar.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
