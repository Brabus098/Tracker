//  TrackerTests.swift

import XCTest
import SnapshotTesting
@testable import Tracker
import Testing

final class AlpabetTests: XCTestCase {
    
    func testViewController() {
        setupTabBarAppearanceForTests()
        let tab = setUpControllers()
        assertSnapshot(of: tab, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testBlackViewController() {
        setupTabBarAppearanceForTests()
        let tab = setUpControllers()
        assertSnapshot(of: tab, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
    private func setUpControllers() -> UITabBarController {
        
        let trackNavigationController = setupPlusController()
        let statisticController = setupStatisticController()
        let tabBarController = setupTabBar(firstController: trackNavigationController, secondController: statisticController)
        //tabBarController.tabBar.tintColor = .red // для теста светлой/темной темы
        
        XCTAssertNotNil(UIImage(named: "statisticTabBarLogo"))
        
        return tabBarController
    }
    
    private func setupPlusController() -> PlusNavigationController {
        let model = RegularTrackModel()
        let storeReader = TrackerStoreReader()
        let recordStore = TrackerRecordStore()
        lazy var trackCollection = TrackCollection(trackerStore: storeReader, recordStore: recordStore)
        let userDefaults = FiltersUserDefaults()
        let viewModel = TrackViewModel(for: model)
        let trackController = TrackersViewController(track: trackCollection, viewModel: viewModel, filterUserDefaults: userDefaults)
        trackController.tabBarItem = UITabBarItem(
            title: String(localized: "Trackers"),
            image: UIImage(named: "tracTabBarLogo"),
            selectedImage: UIImage(named: "tracTabBarLogo"))
        
        return PlusNavigationController(rootViewController: trackController)
    }
    
    private func setupStatisticController() -> StatisticController {
        
        let controller = StatisticController()
        controller.tabBarItem = UITabBarItem(
            title: String(localized: "Statistics"),
            image: UIImage(named: "statisticTabBarLogo"),
            selectedImage: UIImage(named: "statisticTabBarLogo"))
        
        return controller
    }
    
    private func setupTabBar(firstController: PlusNavigationController, secondController: StatisticController) -> UITabBarController {
        let tabBarController = UITabBarController()
        let color = Colors()

        tabBarController.setViewControllers([firstController, secondController], animated: true)

        tabBarController.additionalSafeAreaInsets = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        
        let borderView = UIView()
        borderView.backgroundColor = color.colorForSeparator
        borderView.translatesAutoresizingMaskIntoConstraints = false
        tabBarController.tabBar.addSubview(borderView)

        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: tabBarController.tabBar.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: tabBarController.tabBar.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo:tabBarController.tabBar.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
        return tabBarController
    }
    
    private func setupTabBarAppearanceForTests() {
        // Принудительно для всех tab bar в тестах
        UITabBar.appearance().tintColor = .systemBlue
        UITabBar.appearance().unselectedItemTintColor = .systemGray
    }

}
