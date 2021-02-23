import Foundation

class FavoriteViewModel {
    
    var songPlayingID: Int?
    var favorites = [FavoriteManagedObject]()
    let player = Player.shared
    private var songs = Player.shared.songs
    
    // MARK: - Play Music
    
    func playMusic(with track: Track) {
        player.addSongPlayer(streamUrl: track.streamURL) { done in
            if done {
                player.playMusic(with: track)
                songPlayingID = track.trackID
            }
        }
    }
    
    // MARK: - CoreData
    
    func saveFavorite(id: Int?) {
        if let id = id {
            player.saveFavorite(id: id)
        }
    }
    
    func removeFavorite(id: Int?) {
        if let id = id {
            player.removeFavorite(id: id)
        }
    }
    
    func fetchFavorite() {
        favorites = CoreDataManager.Favorite.fetchData()
    }
    
    func isLiked(with id: Int) -> Bool {
        return CoreDataManager.Favorite.findItem(with: id)
    }
    
    func fetchTrackPlaying() -> PlayingManagedObject?{
        if let playing = player.fetchTrackPlaying() {
            songPlayingID = Int(playing.id)
            return playing
        }
        
        return nil
    }
    
    func saveSongPlaying(with track: Track) {
        player.saveSongPlaying(with: track)
    }
}
