//  CreateCategoryModel.swift

final class CreateCategoryModel {
    
    func saveNewCategory(title: String, at store:AddNewCategoryStore ){
        do {
            try store.addNewCategoryName(title: title)
        } catch {
            print("[CreateCategoryModel]: ошибка при сохранении трека в AddNewCategoryStore: \(error)")
        }
    }
    
    func loadData(from store: AddNewCategoryStore) -> [String] {
        store.loadAllCategoriesTitle()
    }
    
    func deleteCategory(with title: String, at store: AddNewCategoryStore) {
        try? store.deleteCategory(titleWith: title)
    }
    
    func update(old title: String, from newTitle: String, at store: AddNewCategoryStore){
        store.update(old: title, from: newTitle)
    }
}


