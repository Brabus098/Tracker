//  PlusNavigationController.swift

import UIKit

final class PlusNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar(){
        navigationBar.tintColor = .black
        navigationBar.backgroundColor = .white
    }
}
