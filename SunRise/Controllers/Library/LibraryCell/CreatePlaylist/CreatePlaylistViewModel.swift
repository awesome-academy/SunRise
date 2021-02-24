import Foundation

class CreatePlaylistViewModel {
    
    // MARK: - CoreData
    
    func savePlaylistName(with name: String?) {
        if let name = name {
            CoreDataManager.Playlist.addPlaylist(playlistName: name)
        }
    }
}
