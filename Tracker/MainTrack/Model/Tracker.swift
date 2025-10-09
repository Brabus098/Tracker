//  Tracker.swift

// Сущность для хранения инфы о трекере привычки и нерегулярные события
struct Tracker {
    let id: UInt
    let name: String
    let color: String
    let emoji: String
    let timeTable: TimeTabel
}

struct TimeTabel {
    let dayCount: Int
    let dayOfWeek: [WeekDay]
}

// Дни недели для отображения на экране создания трека
enum WeekDay: String {
    case Monday = "Пн"
    case Tuesday = "Вт"
    case Wednesday = "Ср"
    case Thursday = "Чт"
    case Friday = "Пт"
    case Saturday = "Сб"
    case Sunday = "Вс"
    
    func toWeekDays() -> WeekDays? {
        switch self {
        case .Monday: return .Monday
        case .Tuesday: return .Tuesday
        case .Wednesday: return .Wednesday
        case .Thursday: return .Thursday
        case .Friday: return .Friday
        case .Saturday: return .Saturday
        case .Sunday: return .Sunday
        }
    }
}

// Дни недели для сохранения рекорда
enum WeekDays: Int {
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    case Sunday = 1
    
    func toWeekDay() -> WeekDay? {
        switch self {
        case .Monday: return .Monday
        case .Tuesday: return .Tuesday
        case .Wednesday: return .Wednesday
        case .Thursday: return .Thursday
        case .Friday: return .Friday
        case .Saturday: return .Saturday
        case .Sunday: return .Sunday
        }
    }
}

import UIKit

// Выбор цвета трека

extension String {
    func toUIColor() -> UIColor {
        switch self {
        case "color1": return UIColor.color1
        case "color2": return UIColor.color2
        case "color3": return UIColor.color3
        case "color4": return UIColor.color4
        case "color5": return UIColor.color5
        case "color6": return UIColor.color6
        case "color7": return UIColor.color7
        case "color8": return UIColor.color8
        case "color9": return UIColor.color9
        case "color10": return UIColor.color10
        case "color11": return UIColor.color11
        case "color12": return UIColor.color12
        case "color13": return UIColor.color13
        case "color14": return UIColor.color14
        case "color15": return UIColor.color15
        case "color16": return UIColor.color16
        case "color17": return UIColor.color17
            
        default: return UIColor.systemGray
        }
    }
}
