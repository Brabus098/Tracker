//  RegularTrackViewModel.swift

import Foundation

typealias Binding<T> = (T) -> Void

final class TrackViewModel {
    var regularTrackDidAdd: Binding<[TrackerCategory]>?
    var unregularTrackDidAdd: Binding<[TrackerCategory]>?
    private let model: RegularTrackModel
    
    // TextField
    var titleOfTrack: Binding<String>?
    var timeForRepeat: Binding<TimeTabel>?
    var categoryArrayForCellsUpdate: Binding<Bool>?
    var daysForRepeatArrayForController: Binding<String>?
    
    // Обновление ячейки категории
    var indexPathChooseTitle: Binding<IndexPath>?
    var titleOfCategory: Binding<String>?
    private var statusOfOperation = Int() // хранит состояние заполнености ячеек
    
    // Работа searchBar
    var searchStatus: Binding<Bool>?
    
    // MARK: Заполнение контроллера с изменениями
    var actualRecordCount: Binding<String>?
    var goalTrack: Binding<String>?
    var chooseEmoji: Binding<String>?
    var chooseColor: Binding<String>?
    var oldTimeTable: Binding<TimeTabel>?
    var limitLabel: Binding<Bool>?
    
    // Для обновления коллекции после добавления нерегулярного действия
    var needToUpdateCollection: Binding<Bool>?
    
    private var daysForRepeatArray = [String]() // временное хранение дней для повторения
    
    init(for model: RegularTrackModel) {
        self.model = model
        addNotification()
    }
    
    private func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateSearchStatus), name: NSNotification.Name("TextEnter"), object: nil)
    }
    
    @objc func updateSearchStatus(notification: NSNotification){
        if let status = notification.userInfo, let result = status["Status"] as? Bool {
            searchStatus?(result)
        }
    }
}

// MARK: View model -> Model
extension TrackViewModel {
    
    func getActualRecord(trackTitleForSearch: String){
        actualRecordCount?(model.backOldValue(track: trackTitleForSearch))
    }
    
    func getActualTrackGoal(forTrack name: String){
        goalTrack?(model.giveGoal(for: name))
    }
    
    func getActualColor(forTrack name: String) {
        chooseColor?(model.giveColor(for: name))
    }
    
    func getActualEmoji(forTrack name: String) {
        chooseEmoji?(model.giveEmoji(for: name))
    }
    
    func loadActulCategoryTitle(trackTitle: String) {
        let result = model.loadTitleOfCategory(trackTitle: trackTitle)
        titleOfCategory?(result)
    }
    
    func loadActualDays(trackTitle: String) {
        let totalSting = model.loadActualDays(title: trackTitle)
        daysForRepeatArrayForController?(totalSting)
    }
    
    func createTimeTableForOldValues()  {
        let timeTable = model.createTimeTable()
        switch timeTable{
        case .success(let newValue):
            
            oldTimeTable?(newValue)
        case .failure(let error):
            print("[TrackViewModel]: \(error)")
        }
    }
    
    func updateValueAtDataBase(trackWithGoalTitle: String,
                               newTimeTable: [WeekDay]?,
                               newCategoryTitle: String?,
                               newEmoji: String?,
                               newTrackName: String?,
                               newColor: String?){
        model.updateDataBase(trackWithGoalTitle: trackWithGoalTitle, newTimeTable: newTimeTable, newCategoryTitle: newCategoryTitle, newEmoji: newEmoji, newTrackName: newTrackName, newColor: newColor)
  
    }
    
    func fixStateFor(trackTitle: String, state: MenuActions){
        switch state {
        case .fix : model.fixSection(with: "0_Закрепленные", to: trackTitle)
        case .unFix :
            model.unFixSection(to: trackTitle)
        default: print("[TrackViewModel]: Переданно не корректное состояние в fixStateFor")
        }
    }
    
    // Метод вызываемый Вью который опопвещает об заполнении всех полей
    func addTrackWith(titleOfCategory: String,
                      titleOfTrack: String,
                      timeTable: TimeTabel, emojiCol: EmojiCollectionProtocol, colorCol: ColorCollectionProtocol) {
        let emoji = emojiCol.chooseEmoji
        let color = colorCol.chooseColor
        
        let result = model.addNewTrackWith(titleOfCategory: titleOfCategory, titleOfTrack: titleOfTrack, color: color, emoji: emoji, timeTable: timeTable)
        
        switch result {
        case .success(let newTrack):
            regularTrackDidAdd?(newTrack)
        case .failure(let error):
            print("[TrackViewModel]: \(error) to create a track")
        }
    }
    
    // Метод вызываемый из анрегулар контроллера
    func addUnRegularTrackWith(titleOfCategory: String,
                               titleOfTrack: String,
                               date: String,
                               emojiCol: EmojiCollectionProtocol,
                               colorCol: ColorCollectionProtocol, store: TrackerCategoryStore) {
        let emoji = emojiCol.chooseEmoji
        let color = colorCol.chooseColor
        model.addUnRegularTrackWith(titleOfCategory: titleOfCategory,
                                    titleOfTrack: titleOfTrack,
                                    color: color,
                                    emoji: emoji,
                                    dateOfCreated: date,
                                    store: store)
        print("Обновляем needToUpdateCollection")
        needToUpdateCollection?(true)
    }
}


// Методы для обновления дней выполнения
extension TrackViewModel {
    func updateCategoryTitleAndRepeatDays(userInput: [String: Any]){
        
        model.updateArrayWithData(userInput: userInput) // наполняем массив внутри модели данными
        let categoryTile = model.updateTitleCategory() // обновляем название категории
        
        let shortDayForTableView = model.updateDaysForRepeats()
        switch shortDayForTableView {
        case .success(let newDays):
            daysForRepeatArrayForController?(newDays)
            statusOfOperation += 1
        case .failure(let error):
            print("[TrackViewModel]: \(error)")
        }
        
        let timeTable = model.createTimeTable()
        switch timeTable{
        case .success(let newValue):
            timeForRepeat?(newValue)
            statusOfOperation += 1
        case .failure(let error):
            print("[TrackViewModel]: \(error)")
        }
        checkToCompleteEditing()
    }
    
    func checkToCompleteEditing(){
        // Если на момент создания дней категория уже заполнена оповещаем систему
        if statusOfOperation == 2 {
            categoryArrayForCellsUpdate?(true)
        }
    }
}

// CustomTextFieldProtocol Методы вызываемые текст филдом
extension TrackViewModel: TextFieldViewModelProtocol {
    
    // Метод обновления тайтла
    func update(title: String) {
        titleOfTrack?(title)
    }
    
    // Метод обновления лейауйтов
    func updateLayout(and showLimit: Bool) {
        limitLabel?(showLimit)
    }
}

// Методы вызываемые AddNewCategoryController в момент когда выбрана новая категория
extension TrackViewModel {
    func updateCategory(name title: String, state status: IndexPath) {
        titleOfCategory?(title) // Обновляем название категории
        indexPathChooseTitle?(status)
    }
}
