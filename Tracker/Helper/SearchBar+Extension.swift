//  Extension+SearchBar.swift
import UIKit

extension UISearchBar {
    
    func removeSystemPadding() {
        self.backgroundImage = UIImage()
        
        if let container = self.subviews.first?.subviews.first(where: {
            String(describing: type(of: $0)).contains("SearchContainer")
        }) {
            container.constraints.forEach { $0.isActive = false }
            
            container.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                container.topAnchor.constraint(equalTo: self.topAnchor),
                container.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
        
        self.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.searchTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.searchTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.searchTextField.topAnchor.constraint(equalTo: self.topAnchor),
            self.searchTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
