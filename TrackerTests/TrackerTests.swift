//  TrackerTests.swift

import XCTest
import SnapshotTesting
@testable import Tracker
import Testing

final class AlpabetTests: XCTestCase {
    
    func testViewController() {
        let model = RegularTrackModel()
        let storeReader = TrackerStoreReader()
        let recordStore = TrackerRecordStore()
        lazy var trackCollection = TrackCollection(trackerStore: storeReader, recordStore: recordStore)
        
        let viewModel = TrackViewModel(for: model)
        let trackController = TrackersViewController(track: trackCollection, viewModel: viewModel)
        trackController.tabBarItem = UITabBarItem(
            title: String(localized: "Trackers"),
            image: UIImage(named: "tracTabBarLogo"),
            selectedImage: UIImage(named: "tracTabBarLogo"))

        let trackNavigationController = PlusNavigationController(rootViewController: trackController)
        
        let statisticController = StatisticController()

        statisticController.tabBarItem = UITabBarItem(
            title: String(localized: "Statistics"),
            image: UIImage(named: "statisticTabBarLogo"),
            selectedImage: UIImage(named: "statisticTabBarLogo"))
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([trackNavigationController, statisticController], animated: true)
        
        tabBarController.additionalSafeAreaInsets = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        
        tabBarController.tabBar.layer.masksToBounds = true
        tabBarController.tabBar.layer.borderWidth = 1
        tabBarController.tabBar.layer.borderColor = UIColor.lightGray.cgColor

        XCTAssertNotNil(UIImage(named: "statisticTabBarLogo"))
        
        assertSnapshot(of: tabBarController, as: .image)
    }
}
