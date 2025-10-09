//  StatisticViewModel.swift

final class StatisticViewModel: CheckStatisticUpdateProtocol {
    
    var bestScore: Binding<Int>?
    var actualRecord: Binding<Int>?
    var finishTrackers: Binding<Int>?
    var midValueRecord: Binding<Int>?
    
    var closeTable: Binding <Bool>?
    private var model: StatisticModel
    
    init(model: StatisticModel) {
        self.model = model
    }
    
    func checkUpdate() {
        let result = model.check()
        
        if let first = result["actualRecordValue"], let second = result["perfectDays"],
           let third = result["finishTrackers"] ,
           let forth = result["midRecord"],
           first + second + third + forth > 0 {
            closeTable?(false)
        } else {
            closeTable?(true)
        }
        
        for (key, value) in result {
            switch key {
            case "actualRecordValue": bestScore?(value)
            case "perfectDays": actualRecord?(value)
            case "finishTrackers": finishTrackers?(value)
            case "midRecord": midValueRecord?(value)
            default:
                print("[StatisticViewModel]: пришло неизвестное значение из кордаты")
            }
        }
    }
    
    func cleanData() {
        model.removeData()
    }
}
