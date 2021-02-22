import Foundation
import CoreData

@objc(PlayingManagedObject)
public class PlayingManagedObject: NSManagedObject {

}

extension PlayingManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayingManagedObject> {
        return NSFetchRequest<PlayingManagedObject>(entityName: "Playing")
    }

    @NSManaged public var artworkURL: String?
    @NSManaged public var genre: String?
    @NSManaged public var id: Int32
    @NSManaged public var streamURL: String?
    @NSManaged public var title: String?
    @NSManaged public var userID: String?
    @NSManaged public var userName: String?

}

extension PlayingManagedObject : Identifiable {

}
