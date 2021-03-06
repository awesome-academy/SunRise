import Foundation
import UIKit
import CoreData

extension CoreDataManager.Playlist {
    
    static func addTrackToPlaylist<T>(playlistName: String, with track: T) {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            let playlistMO = PlaylistManagedObject(context: managedContext)
            
            if let track = track as? Track {
                playlistMO.setData(playlistName: playlistName, resource: track)
            }
            else if let track = track as? FavoriteManagedObject{
                playlistMO.setData(playlistName: playlistName, resource: track)
            }
            else if let track = track as? PlaylistManagedObject{
                playlistMO.setData(playlistName: playlistName, resource: track)
            }
        
            do {
                try managedContext.save()
            } catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    static func addPlaylist(playlistName: String) {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            let playlistMO = PlaylistManagedObject(context: managedContext)
            
            playlistMO.playlistName = playlistName
        
            do {
                try managedContext.save()
            } catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    static func remove(with id: Int) {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            
            let request: NSFetchRequest<PlaylistManagedObject> = PlaylistManagedObject.fetchRequest()
            
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
    
    static func removePlaylist(with name: String) {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            
            let request: NSFetchRequest<PlaylistManagedObject> = PlaylistManagedObject.fetchRequest()
            
            request.predicate = NSPredicate(format: "playlistName = %@", name)
            
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
    
    static func fetchData() -> [PlaylistManagedObject] {
        if let managedContext = CoreDataManager.appDelegate?.persistentContainer.viewContext {
            let request: NSFetchRequest<PlaylistManagedObject> = PlaylistManagedObject.fetchRequest()
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try managedContext.fetch(request)
                return result
            } catch {
                print("Fetch request failed")
                return [PlaylistManagedObject]()
            }
        }
        return [PlaylistManagedObject]()
    }
    
    static func findItem(playlistName: String, with id: Int) -> Bool {
        let request: NSFetchRequest<PlaylistManagedObject> = PlaylistManagedObject.fetchRequest()
        request.predicate = NSPredicate(format: "(playlistName = %@) AND (id == %i)", playlistName, id)
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
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
