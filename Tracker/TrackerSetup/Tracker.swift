//  Tracker.swift

// Сущность для хранения инфы о трекере привычки и нерегулярные события
struct Tracker{
    let id: UInt
    let name: String
    let color: Color
    let emoji: String
    let timeTable: TimeTabel
}

struct TimeTabel{
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
}
// Выбор цвета трека
enum Color{
    case green
    case red
    case yellow
    case orange
}

