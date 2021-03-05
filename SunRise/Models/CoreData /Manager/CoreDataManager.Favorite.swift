import Foundation
import UIKit
import CoreData

extension CoreDataManager.Favorite {
    
    static func save<T>(with track: T) {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            let favoriteMO = FavoriteManagedObject(context: managedContext)
            
            if let track = track as? Track {
                favoriteMO.setData(resource: track)
            }
            else if let track = track as? FavoriteManagedObject{
                favoriteMO.setData(resource: track)
            }
            else if let track = track as? PlaylistManagedObject{
                favoriteMO.setData(resource: track)
            }
            else if let track = track as? PlayingManagedObject{
                favoriteMO.setData(resource: track)
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    static func remove(with id: Int) {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            
            let request: NSFetchRequest<FavoriteManagedObject> = FavoriteManagedObject.fetchRequest()
            
            request.predicate = NSPredicate(format: "id == \(id)")
            
            do {
                let items = try managedContext.fetch(request)
                for item in items {
                    managedContext.delete(item)
                }
                try managedContext.save()
            } catch {
                print("Error fetching data \(error)")
            }
        }
    }
    
    static func fetchData() -> [FavoriteManagedObject] {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            let request: NSFetchRequest<FavoriteManagedObject> = FavoriteManagedObject.fetchRequest()
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try managedContext.fetch(request)
                return result
            } catch {
                print("Fetch request failed")
                return [FavoriteManagedObject]()
            }
        }
        return [FavoriteManagedObject]()
    }
    
    static func findItem(with id: Int) -> Bool {
        let request: NSFetchRequest<FavoriteManagedObject> = FavoriteManagedObject.fetchRequest()
        request.predicate = NSPredicate(format: "id == %i", id)
        request.sortDescriptors = [NSSortDescriptor(key: "id",
                                   ascending: true)]
        
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            do {
                let items = try managedContext.fetch(request)
                
                if items.isEmpty {
                    return false
                } else {
                    return true
                }
            } catch {
                print("Error fetching data \(error)")
            }
        }
        return false
    }
    
    func deleteAllObject() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
