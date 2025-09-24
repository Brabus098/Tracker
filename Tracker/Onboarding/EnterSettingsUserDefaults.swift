//  EnterSettingsUserDefaults.swift

protocol CheckEnterProtocol: AnyObject {
    var enterStatus: Bool { get set} // Статус просмотра онбординга
}

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
