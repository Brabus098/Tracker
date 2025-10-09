import Foundation

//  StatisticModel.swift

final class StatisticModel {
    
    private let store = TrackerStoreReader()
    
    // Records
    private var dateDictionary = [String:Int]()
    private var periodOfDateArray = [String]()
    // Counters
    private var actualRecordValue = 0
    private var perfectDayCount = 0
    
    // Date
    private lazy var dateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(identifier: "UTC")
        dateFormat.dateFormat = "dd.MM.yyyy"  // задаём формат, соответствующий входной строке
        return dateFormat
    }()
    private let todayDate = Date()
    private var dateOfLastRecord = Date()
    private let calendar = Calendar.current
    
    
    func check() -> [String: Int] {
        var dictToReturn = [String: Int]()
        dictToReturn["finishTrackers"] = checkFinishTrackers() // Трекеров завершенно
        dictToReturn["midRecord"] = checkMidValueRecord()  // Проверяем среднее значение
        actualRecord()
        dictToReturn["perfectDays"] = perfectDayCount // Лучший период
        dictToReturn["actualRecordValue"] = actualRecordValue  // Идеальные дни
        return dictToReturn
    }
    
    // Идеальные дни
    private func actualRecord() {
        // Найти идеальное количество дней и создать словарь
        let dictWithNeededTrackForDay = store.loadCountTrackForDayOfWeek()
        findActualRecord(dict: dictWithNeededTrackForDay)
    }
    
    // Трекеров завершенно
    private func checkFinishTrackers() -> Int {
        let dataArray = store.loadDate()
        var dictWithDate = [String:Int]()
        for i in dataArray { dictWithDate[i, default: 0] += 1 }
        dateDictionary = dictWithDate
        let firstValueToReturn = dateDictionary.count
        return dictWithDate.count
    }
    
    // Проверяем среднее количество выполняемых треков в день
    private func checkMidValueRecord() -> Int {
        let minDate = returnMinValueAt()
        let dayCountAfterFirstTrackToStart = returnDayCountAfter(firstDay: minDate)
        let counterTrackerDidAdd = findCountTrackersDidAdd()
        guard counterTrackerDidAdd != 0 && dayCountAfterFirstTrackToStart != 0 else { return 0 }
        
        return counterTrackerDidAdd / dayCountAfterFirstTrackToStart
    }
    
    // Метод находят идеальные дни и определяет актуальный рекорд
    private func findActualRecord( dict: [WeekDay : Int]) {
        var localValueRecord = 0
        for i in periodOfDateArray {
            // Проверяем есть ли он у нас в словаре
            guard dictContains(date: i), let dateFormatted = dateFormatter.date(from: i) else { continue } // если такого дня нету в рекорде продолжаем
            let result = returnWeekDay(from: dateFormatted) // Определяем какой это день недели
            if let allTrackForDay = dict[result ?? .Monday], // Смотрим оптимальное количество дней для этого дня недели
               let didTrackers = dateDictionary[i] { // сколько треков выполнено
                
                if allTrackForDay == didTrackers {
                    perfectDayCount += 1 // +1 идеальный день
                    let newRecordStateChanged = isToBackDay(nextDayDate: i) // проверяем подяд ли идут даты
                    if newRecordStateChanged && localValueRecord + 1 > localValueRecord {
                        localValueRecord += 1 // обновляем локальный рекорд
                        actualRecordValue = localValueRecord // обновляем глобальный рекорд
                        dateOfLastRecord = dateFormatter.date(from: i) ?? Date() // сохранить день
                    } else if !newRecordStateChanged {
                        localValueRecord = 1 // обновляем локальный рекорд
                        updateActualRecordIfNeeded()
                        dateOfLastRecord = dateFormatter.date(from: i) ?? Date() // сохранить день
                    }
                }
            }
        }
    }
    
    func removeData(){
        actualRecordValue = 0
        perfectDayCount = 0
    }
}

// Методы помогающие найти идеальный день и новую ркордную серию
extension StatisticModel {
    
    private func returnWeekDay(from day: Date) -> WeekDay? {
        let weekday = WeekDays(rawValue: calendar.component(.weekday, from: day))
        let result =  weekday?.toWeekDay()
        return result
    }
    
    private func dictContains(date: String) -> Bool {
        return dateDictionary.contains(where: {$0.key == date})
    }
    
    private func updateActualRecordIfNeeded(){
        if 1 > actualRecordValue {
            actualRecordValue = 1
        }
    }
    
    private func isToBackDay(nextDayDate: String) -> Bool {
        if let actualDate = dateFormatter.date(from: nextDayDate),
           let backDate = calendar.date(byAdding: .day, value: -1, to: actualDate),
           dateOfLastRecord == backDate {
            return true
        }
        return false
    }
}

// Методы помогающие найти среднее треков/день
extension StatisticModel {
    
    // Метод находит количество треков выполненых за период
    private func findCountTrackersDidAdd() -> Int {
        var counter = 0
        for i in dateDictionary {
            counter += i.value
        }
        return counter
    }
    
    // Метод возвращает количество дней от первого дня до сегодняшнего
    private func returnDayCountAfter(firstDay: Date?) -> Int {
        guard let firstDay else { return 0 }
        
        var arrayToReturn = [String]()
        var currentDate = firstDay
        
        while currentDate <= todayDate {
            
            arrayToReturn.append(dateFormatter.string(from: currentDate))
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        periodOfDateArray = arrayToReturn // запоминаем пириод
        return arrayToReturn.count
    }
    
    // Метод находит первый день когда хотя бы один трек был выполнен
    private func returnMinValueAt() -> Date? {
        var array = [Date]()
        
        for i in dateDictionary {
            let dateString = i.key
            
            if let date = dateFormatter.date(from: dateString) {
                array.append(date)
            }
        }
        return array.min()
    }
}
