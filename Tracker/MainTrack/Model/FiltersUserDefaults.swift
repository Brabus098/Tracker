//  FiltersUserDefaults.swift

protocol FiltersProtocol: AnyObject {
    var chooseFilter: FiltersForTrackCollection { get set }
}

import Foundation

final class FiltersUserDefaults: FiltersProtocol {
    let userDefaults = UserDefaults.standard
    
    var chooseFilter: FiltersForTrackCollection {
        get {
            FiltersForTrackCollection(rawValue: userDefaults.string(forKey: "filter") ?? "Все трекеры") ?? .allTracks
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: "filter")
        }
    }
}
