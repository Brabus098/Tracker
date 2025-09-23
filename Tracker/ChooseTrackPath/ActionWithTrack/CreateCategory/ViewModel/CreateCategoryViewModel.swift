//  CreateCategoryViewModel.swift

final class CreateCategoryViewModel: TextFieldViewModelProtocol{
    
    private let model: CreateCategoryModel
    let newCategoryStore = AddNewCategoryStore()
    
    var limitLabelStatus: Binding<Bool>?
    var newTitle: Binding<String>?
    var actualTitleUpdate: Binding <Bool>?
    var actualDataSourceCounter: Binding <Int>?
    
    var actualTitleArray: [String] = [String]() {
        didSet { actualTitleUpdate?(true) }
    }
    
    init(model: CreateCategoryModel) {
        self.model = model
        loadAddedTitle()
        newCategoryStore.delegate = self
    }
    
    func save(title: String){
        model.saveNewCategory(title: title, at: newCategoryStore)
        actualValueFromArray()
    }
    
    func remove(title: String) {
        model.deleteCategory(with: title, at: newCategoryStore)
        actualValueFromArray()
    }
    
    func edit(oldCategory name: String,from newName: String){
        model.update(old: name, from: newName, at: newCategoryStore)
    }
}

// Methods calls TextField
extension CreateCategoryViewModel {
    func update(title: String) {
        newTitle?(title)
    }
    
    func updateLayout(and showLimit: Bool) {
        limitLabelStatus?(showLimit)
    }
}

// Method calls after reload App for download actual list of title
extension CreateCategoryViewModel {
    func loadAddedTitle() {
        let stringToReturn = model.loadData(from: newCategoryStore)
        actualTitleArray = stringToReturn
    }
    
    func actualValueFromArray(){
        let stringToReturn = model.loadData(from: newCategoryStore)
        actualDataSourceCounter?(stringToReturn.count)
    }
}

// Метод обрабатывает обратный ответ от кордаты с загруженными данными
extension CreateCategoryViewModel: UpdateViewModelDelegate {
    func upload(new array:[String]) {
        actualTitleArray = array
    }
}

