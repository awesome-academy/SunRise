import Foundation
import UIKit
import CoreData

extension CoreDataManager.Playing {

    static func save<T>(with track: T) {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            let playingMO = PlayingManagedObject(context: managedContext)
            
            if let track = track as? Track {
                playingMO.setData(resource: track)
            }
            else if let track = track as? FavoriteManagedObject{
                playingMO.setData(resource: track)
            }
        
            do {
                try managedContext.save()
            } catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    static func fetchData() -> [PlayingManagedObject]? {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            let request: NSFetchRequest<PlayingManagedObject> = PlayingManagedObject.fetchRequest()
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try managedContext.fetch(request)
                return result
            } catch {
                print("Fetch request failed")
                return nil
            }
        }
        return nil
    }
    
    static func deleteAllObject() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Playing")

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
