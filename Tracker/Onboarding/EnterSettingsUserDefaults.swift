//  EnterSettingsUserDefaults.swift

import UIKit

final class EnterSettingsUserDefaults {
    let userDefaults = UserDefaults.standard
    
    var enterStatus: Bool {
        get {
            userDefaults.bool(forKey: "EnterKey")
        }
        set {
            userDefaults.set(newValue, forKey: "EnterKey")
        }
    }
}
