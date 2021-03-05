import Foundation
import CoreData

@objc(FavoriteManagedObject)
public class FavoriteManagedObject: NSManagedObject {
    
}

extension FavoriteManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteManagedObject> {
        return NSFetchRequest<FavoriteManagedObject>(entityName: "Favorite")
    }

    @NSManaged public var artworkURL: String?
    @NSManaged public var genre: String?
    @NSManaged public var id: Int32
    @NSManaged public var streamURL: String?
    @NSManaged public var title: String?
    @NSManaged public var userID: String?
    @NSManaged public var userName: String?
    
    func setData( resource track: Track) {
        self.id = Int32(track.trackID ?? 0)
        self.title = track.title
        self.genre = track.genre
        self.artworkURL = track.artworkURL
        self.streamURL = track.streamURL
        self.userName = track.userName
    }
    
    func setData( resource track: FavoriteManagedObject) {
        self.id = track.id
        self.title = track.title
        self.genre = track.genre
        self.artworkURL = track.artworkURL
        self.streamURL = track.streamURL
        self.userName = track.userName
    }
    
    func setData( resource track: PlaylistManagedObject) {
        self.id = track.id
        self.title = track.title
        self.genre = track.genre
        self.artworkURL = track.artworkURL
        self.streamURL = track.streamURL
        self.userName = track.userName
    }
    
    func setData( resource track: PlayingManagedObject) {
        self.id = track.id
        self.title = track.title
        self.genre = track.genre
        self.artworkURL = track.artworkURL
        self.streamURL = track.streamURL
        self.userName = track.userName
    }
}

extension FavoriteManagedObject : Identifiable {

}
