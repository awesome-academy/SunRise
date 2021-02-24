import Foundation

class PlaylistViewModel {
    
    private var favorites = [FavoriteManagedObject]()
    var playlists = [PlaylistManagedObject]()
    let player = Player.shared
    var songs = [String: [Track]]() {
        didSet {
            player.songs = songs
        }
    }
    
    init(playlists: [PlaylistManagedObject]) {
        self.playlists = playlists
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
