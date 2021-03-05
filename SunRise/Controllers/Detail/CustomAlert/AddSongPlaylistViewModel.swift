import Foundation

final class AddSongPlaylistViewModel {
    
    private var playlists = [String : [PlaylistManagedObject]]() {
        didSet {
            playlistNames = Array(playlists.keys).sorted()
        }
    }
    var playlistNames = [String]()
    
    // MARK: CoreData
    
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
}
