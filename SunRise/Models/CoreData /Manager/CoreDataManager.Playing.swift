import Foundation
import UIKit
import CoreData

extension CoreDataManager.Playing {

    static func save(with track: Track) {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            let playingMO = PlayingManagedObject(context: managedContext)
            
            playingMO.id = Int32(track.trackID ?? 0)
            playingMO.title = track.title
            playingMO.genre = track.genre
            playingMO.artworkURL = track.artworkURL
            playingMO.streamURL = track.streamURL
            playingMO.userName = track.userName
        
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
