import Foundation
import CoreData

@objc(PlaylistManagedObject)
public class PlaylistManagedObject: NSManagedObject {

}

extension PlaylistManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistManagedObject> {
        return NSFetchRequest<PlaylistManagedObject>(entityName: "Playlist")
    }

    @NSManaged public var artworkURL: String?
    @NSManaged public var genre: String?
    @NSManaged public var id: Int32
    @NSManaged public var playlistName: String?
    @NSManaged public var streamURL: String?
    @NSManaged public var title: String?
    @NSManaged public var userID: String?
    @NSManaged public var userName: String?

    func setData( playlistName: String, resource track: Track) {
        self.playlistName = playlistName
        self.id = Int32(track.trackID ?? 0)
        self.title = track.title
        self.genre = track.genre
        self.artworkURL = track.artworkURL
        self.streamURL = track.streamURL
        self.userName = track.userName
    }
    
    func setData( playlistName: String, resource track: FavoriteManagedObject) {
        self.playlistName = playlistName
        self.id = track.id
        self.title = track.title
        self.genre = track.genre
        self.artworkURL = track.artworkURL
        self.streamURL = track.streamURL
        self.userName = track.userName
    }
    
    func setData( playlistName: String, resource track: PlaylistManagedObject) {
        self.playlistName = playlistName
        self.id = track.id
        self.title = track.title
        self.genre = track.genre
        self.artworkURL = track.artworkURL
        self.streamURL = track.streamURL
        self.userName = track.userName
    }
}

extension PlaylistManagedObject : Identifiable {

}
