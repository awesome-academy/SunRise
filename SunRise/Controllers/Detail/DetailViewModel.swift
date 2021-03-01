import Foundation
import UIKit

final class DetailViewModel {
    private var favorite: FavoriteManagedObject?
    private var playlist: PlaylistManagedObject?
    private let player = Player.shared
    
    // MARK: - Init
    
    init(track: FavoriteManagedObject) {
        self.favorite = track
    }
    
    init(track: PlaylistManagedObject) {
        self.playlist = track
    }
    
    // MARK: - Public func
    
    func getTitle() -> String {
        return favorite?.title ?? playlist?.title ?? "Invalid"
    }
    
    func getUser() -> String {
        return favorite?.userName ?? playlist?.userName ?? "Invalid"
    }
    
    func getSongImage(completion: @escaping APICompletion<UIImage?>) {
        favorite?.artworkURL?.downloadImage(completion: completion) ?? playlist?.artworkURL?.downloadImage(completion: completion) ?? completion(.failure(.error("Invalid type")))
    }
    
    // MARK: - CoreData
    
    func saveFavorite() {
        CoreDataManager.Favorite.save(with: favorite ?? playlist)
    }
    
    func removeFavorite() {
        CoreDataManager.Favorite.remove(with: Int(((favorite?.id ?? playlist?.id) ?? 0)))
        
    }
    
    func isLiked() -> Bool {
        return CoreDataManager.Favorite.findItem(with: Int(((favorite?.id ?? playlist?.id) ?? 0)))
    }
    
    func addSongToPlaylist() {

    }
    
    func removeSongFromPlaylist() {
        if let playlist = playlist {
            let notification = Notification(name: .removeSongPlaylist, object: playlist, userInfo: nil)
            NotificationCenter.default.post(notification)
        }
    }
}
