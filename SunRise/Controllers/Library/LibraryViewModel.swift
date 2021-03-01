import Foundation

class LibraryViewModel {
    
    private var favorites = [FavoriteManagedObject]()
    var playlists = [String : [PlaylistManagedObject]]() {
        didSet {
            playlistNames = Array(playlists.keys).sorted()
        }
    }
    var playlistNames = [String]()
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
    
    func fetchPlaylist() {
        let playlists = CoreDataManager.Playlist.fetchData()
        let groupByPlaylistName = Dictionary(grouping: playlists) { playlists -> String in
            return (playlists.playlistName ?? "")
        }
        for (key, values) in groupByPlaylistName {
            self.playlists[key] = values
        }
        self.playlists = groupByPlaylistName
    }
    
    func removePlaylist(name: String) {
        CoreDataManager.Playlist.removePlaylist(with: name)
        fetchPlaylist()
    }
}
