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
    
    // Favorite
    func saveFavorite(track: PlaylistManagedObject) {
        CoreDataManager.Favorite.save(with: track)
    }
    
    func removeFavorite(track: PlaylistManagedObject) {
        CoreDataManager.Favorite.remove(with: Int(track.id))
    }
    
    func fetchFavorite() {
        favorites = CoreDataManager.Favorite.fetchData()
    }
    
    func isLiked(with id: Int) -> Bool {
        return CoreDataManager.Favorite.findItem(with: id)
    }
    
    // Player
    func fetchTrackPlaying() -> PlayingManagedObject?{
        return player.fetchTrackPlaying()
    }
    
    func saveSongPlaying(with track: Track) {
        player.saveSongPlaying(with: track)
    }
    
    // Playlist
    func addSongToPlaylist(with track: Track) {
        if let playlistName = playlists.first?.playlistName, let trackID = track.trackID {
            if CoreDataManager.Playlist.findItem(playlistName: playlistName, with: trackID) { return }
            CoreDataManager.Playlist.addTrackToPlaylist(playlistName: playlistName, with: track)
        }
    }
    
    func fetchPlaylist() {
        let newPlaylists = CoreDataManager.Playlist.fetchData()
        let groupByPlaylistName = Dictionary(grouping: newPlaylists) { playlists -> String in
            return (playlists.playlistName ?? "")
        }
        
        if let playlistName = playlists.first?.playlistName {
            playlists = groupByPlaylistName[playlistName] ?? [PlaylistManagedObject]()
        }
    }
    
    func removeTrackPlaylist(element: PlaylistManagedObject) {
        playlists.removeAll(where: { $0.id == element.id })
        CoreDataManager.Playlist.remove(with: Int(element.id))
    }
}
