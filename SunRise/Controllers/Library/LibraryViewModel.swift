import Foundation

class LibraryViewModel {
    
    private var favorites = [FavoriteManagedObject]()
    let player = Player.shared
    var songs = [String: [Track]]() {
        didSet {
            player.songs = songs
        }
    }
    
    // MARK: - CoreData
    
    func saveFavorite() {
        player.saveFavorite(id: player.songPlayingID)
    }
    
    func removeFavorite() {
        player.removeFavorite(id: player.songPlayingID)
    }
    
    func fetchFavorite() {
        favorites = CoreDataManager.Favorite.fetchData()
    }
    
    func isLiked(with id: Int) -> Bool {
        return CoreDataManager.Favorite.findItem(with: id)
    }
    
    func fetchTrackPlaying() -> PlayingManagedObject?{
        return player.fetchTrackPlaying()
    }
    
    func saveSongPlaying(with track: Track) {
        player.saveSongPlaying(with: track)
    }
}
