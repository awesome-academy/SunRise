import Foundation

final class PlayerViewModel {
    
    private var favorites = [FavoriteManagedObject]()
    var songPlaying = PlayingManagedObject()
    let player = Player.shared
    
    // MARK: - Public func
    
    func getRate() -> Float {
        return Float(player.getSecondCurrentTime() / player.getSecondDuration())
    }
    
    // MARK: - CoreData
    
    func saveFavorite() {
        CoreDataManager.Favorite.save(with: songPlaying)
    }
    
    func removeFavorite() {
        CoreDataManager.Favorite.remove(with: Int(songPlaying.id))
    }
    
    func fetchFavorite() {
        favorites = CoreDataManager.Favorite.fetchData()
    }
    
    func isLiked(with id: Int) -> Bool {
        return CoreDataManager.Favorite.findItem(with: id)
    }
    
    func fetchTrackPlaying(completion: (Bool) -> Void){
        if let track = player.fetchTrackPlaying() {
            songPlaying = track
            completion(true)
            return
        }
        completion(false)
    }
    
    func saveSongPlaying(with track: Track) {
        player.saveSongPlaying(with: track)
    }
    
}
