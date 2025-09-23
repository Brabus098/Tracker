//  AddNewCategoryStore.swift

import CoreData
import UIKit

final class AddNewCategoryStore: NSObject{
    
    let context: NSManagedObjectContext
    weak var delegate: UpdateViewModelDelegate?
    
    private var frc: NSFetchedResultsController<NewNameOfCategoryCoreData>!
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFetchResultController()
    }
    
    // Methods save new title of category
    func addNewCategoryName(title: String) throws{
        let newNameOfCategory = NewNameOfCategoryCoreData(context: context)
        newNameOfCategory.name = title
        
        try context.save()
    }
    
    // Method calls CreateCategoryViewModel after reload App for download actual list of title
    func loadAllCategoriesTitle() -> [String] {
        guard let categories = frc.fetchedObjects else {
            return [String()]
        }
        return categories.compactMap { $0.name }
    }
    
    func deleteCategory(titleWith name: String) throws{
        guard frc.fetchedObjects != nil else { return }
        
        try context.performAndWait {
            let request = NewNameOfCategoryCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", name)
            
            if let titleToDelete = try context.fetch(request).first {
                context.delete(titleToDelete)
                try context.save()
            }
        }
    }
    
    func update(old categoryTitle: String, from newCategoryTitle: String){
        context.performAndWait {
            let request = NewNameOfCategoryCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", categoryTitle)
            
            do {
                if let titleToChange = try context.fetch(request).first {
                    titleToChange.name = newCategoryTitle
                    try context.save()
                }
            } catch {
                print("[AddNewCategoryStore]: Ошибка изменения тайтла")
            }
        }
    }
}

// MARK: create FRC
extension AddNewCategoryStore: NSFetchedResultsControllerDelegate {
    private func setupFetchResultController(){
        let request = NewNameOfCategoryCoreData.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: "name",
                                         cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            print("[AddNewCategoryStore]: ошибка в создании FRC")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let categories = frc.fetchedObjects else { return }
        
        delegate?.upload(new: categories.compactMap { $0.name })
    }
}
