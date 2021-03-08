import Foundation

class SearchViewModel {
    
    var searchHistory: [String] {
        get {
            UserDefaults.standard.array(forKey: "search") as? [String] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "search")
        }
    }
    
    var tracks = [Track]()
    var playlists = [PlaylistManagedObject]()
    let player = Player.shared
    
    // MARK: - Public func
    
    func saveHistory(searchText: String) {
        if searchHistory.contains(searchText) {
            return
        } else {
            searchHistory.append(searchText)
        }
    }
    
    // MARK: - CoreData
    
    func saveFavorite() {
        player.saveFavorite()
    }
    
    func removeFavorite() {
        player.removeFavorite()
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
    
    func getResultSearch(with searchText: String, completion: @escaping (Bool) -> Void) {
        tracks.removeAll()
        APIManager.Music.getResultSearch(with: searchText) { [weak self]result in
            switch result {
            case .failure(_):
                completion(false)
            case .success(let tracks):
                self?.tracks = tracks
                completion(true)
            }
        }
    }
    
    func removeTrack(element: Track) {
        tracks.removeAll(where: { $0.trackID == element.trackID })
    }
}
