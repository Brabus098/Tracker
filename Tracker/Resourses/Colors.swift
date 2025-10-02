//  Colors.swift

import UIKit

final class Colors {
    let colorForSeparator = UIColor {(traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.grey
        } else {
            return UIColor.black
        }
    }
}
