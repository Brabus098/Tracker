//  RegularTrackModel.swift

import UIKit

final class RegularTrackModel {
    
    private var categoryForTracks = [TrackerCategory]() // для сохранения новых трекеров и их последующей передачи
    private var daysForRepeatArray = [String]() // временное хранение дней для повторения
    private var daysDictionary = [String: Any]()
   
    // Метод вызываемый вью моедлью для добавления трека
    func addNewTrackWith(titleOfCategory: String,
                         titleOfTrack: String,
                         color: String,
                         emoji: String,
                         timeTable: TimeTabel) -> Result<[TrackerCategory], Error> {
        
        categoryForTracks.append(TrackerCategory(title: titleOfCategory,
                                                 trackerArray: [Tracker(id: UInt.random(in: 1...10000),
                                                                        name: titleOfTrack,
                                                                        color: color,
                                                                        emoji: emoji,
                                                                        timeTable: timeTable)]))
        if !categoryForTracks.isEmpty {
            return .success(categoryForTracks)
        } else {
            return .failure(TrackerErrors.failToCreateTrack)
        }
    }
    
    func addUnRegularTrackWith(titleOfCategory: String,
                              titleOfTrack: String,
                              color: String,
                              emoji: String,
                               dateOfCreated: String, store: TrackerCategoryStore) {
        var tracker = [TrackerCategory(title: titleOfCategory, trackerArray: [Tracker(id: UInt.random(in: 1...10000),
                                                                                     name: titleOfTrack,
                                                                                     color: color,
                                                                                     emoji: emoji,
                                                                                     timeTable: TimeTabel(dayCount: 0, dayOfWeek: []))])]
        try? store.addNewTrackerCategory(tracker, dateOfCreated: dateOfCreated)
        // Передать в модель данные для сохранения
        // А из модели напрямую в кордата
        // В методе кордата обрабатывать условия для варианта у которого нету данных об количестве дней в которые его нужно отображать, нужно отображать по дате
    }
    
    // Метод обновляет данные сохраненные подьзователем
    func updateArrayWithData(userInput:[String: Any]) {
        daysDictionary = userInput
    }
    
    func updateTitleCategory() -> Result<String, Error>{
        if let categoryString = daysDictionary["Категория"] as? String {
            return .success(categoryString)
        } else {
            return .failure(TrackerErrors.failToCreateTitleForTrack)
        }
    }
    
    func updateDaysForRepeats() -> Result <String, Error> {
        self.daysForRepeatArray.removeAll() // удаляем значения чтобы задать повторно
        let result = createArrayWithDaysOfWeek() // создаем массив с полученными днями недели
        return result.count != 0
        ? .success(result)
        : .failure(TrackerErrors.failToCreateshortDayForTableView)
    }
    
    private func createArrayWithDaysOfWeek() -> String{
        
        daysDictionary.forEach { key, value in
            guard value as? Bool ?? false else { return }
            
            let addValue: String
            
            switch key {
            case "Понедельник": addValue = "Пн"
            case "Вторник": addValue = "Вт"
            case "Среда": addValue = "Ср"
            case "Четверг": addValue = "Чт"
            case "Пятница": addValue = "Пт"
            case "Суббота": addValue = "Сб"
            case "Воскресенье": addValue = "Вс"
                
            default: return // Пропускаем неизвестные ключи
            }
            daysForRepeatArray.append(addValue)
        }
        
        return stringActualValue()
    }
    
    private func stringActualValue() -> String{
        var actualString = ""
        if daysForRepeatArray.count == 7 {
            actualString = "Каждый день"
        } else {
            actualString = daysForRepeatArray.joined(separator: ", ")
        }
        return actualString
    }
    
    func createTimeTable() -> Result <TimeTabel, Error>{
        let returnResult = addShortNameDaysOFWeek()
        return !returnResult.dayOfWeek.isEmpty
        ? .success(returnResult)
        : .failure(TrackerErrors.failtoCreateTimeTabel)
    }
    
    private func addShortNameDaysOFWeek() -> TimeTabel {
        var actualDaysArray = [WeekDay]()
        daysForRepeatArray.forEach { title in
            if let actualDay = WeekDay(rawValue: title) {
                actualDaysArray.append(actualDay)
            }
        }
        // Задаем время для повтора
        return TimeTabel(dayCount: 0, dayOfWeek: actualDaysArray)
    }
}

// MARK: Load data methods from Edit controller
extension RegularTrackModel {
    func backOldValue(track: String) -> String {
        if let result = try? CoreDataManager.shared.backActualRecord(title: track) {
            return result
        } else {
            print("[RegularTrackModel: не удалось получить данные о рекорде из модели]")
        }
        return ""
    }
    
    func giveGoal(for track: String) -> String{
        if let result = try? CoreDataManager.shared.backActualTrackGoal(title: track) {
            return result
        } else {
            print("[RegularTrackModel: не удалось получить данные о цели из модели]")
        }
        return ""
    }
    
    func giveEmoji(for track: String) -> String{
        if let result = try? CoreDataManager.shared.backActualEmoji(title: track) {
            return result
        } else {
            print("[RegularTrackModel: не удалось получить данные о умоджи из модели]")
        }
        return ""
    }
    
    func giveColor(for track: String) -> String{
        if let result = try? CoreDataManager.shared.backActualColor(title: track) {
            return result
        } else {
            print("[RegularTrackModel: не удалось получить данные о цвете из модели]")
        }
        return ""
    }
    
    func loadTitleOfCategory(trackTitle: String) -> String{
        if let result = try? CoreDataManager.shared.loadTitleOfCategory(title: trackTitle) {
            return result
        } else {
            print("[RegularTrackModel: не удалось получить данные о выбранной категории из модели]")
        }
        return ""
    }
    
    func loadActualDays(title: String) -> String {
        if let result = try? CoreDataManager.shared.loadDayForRepeat(title: title) {
            daysForRepeatArray = result
            
            return stringActualValue()
        } else {
            print("[RegularTrackModel: не удалось получить данные о выбранной категории из модели]")
        }
        return ""
    }
}

extension RegularTrackModel {
    func updateDataBase(trackWithGoalTitle: String,
                        newTimeTable: [WeekDay]?,
                        newCategoryTitle: String?,
                        newEmoji: String?,
                        newTrackName: String?,
                        newColor: String?){
        try? CoreDataManager.shared.editOptionsFor(
            trackWithGoalTitle: trackWithGoalTitle,
            newTimeTable: newTimeTable,
            newCategoryTitle: newCategoryTitle,
            newEmoji: newEmoji,
            newTrackName: newTrackName,
            newColor: newColor)
    }
    
    func fixSection(with title: String, to trackTitle: String) {
        try? CoreDataManager.shared.changeCategoryTitle(status: true, trackName: trackTitle, fixTitle: title) // говорим что хотим добавить в закрепленные
    }
    
    func unFixSection(to trackTitle: String){
        try?  CoreDataManager.shared.changeCategoryTitle(status: false, trackName: trackTitle, fixTitle: "")
    }
}
