import Foundation

final class HomeViewModel {
    private var playlists = [Playlist]()
    var songs = [String: [Track]]()
    
    func loadAPI(completion: @escaping (Bool) -> Void) {
        APIManager.Music.getPlaylist() { [weak self]results in
            switch results {
            case .failure(_):
                completion(false)
            case .success(let playlists):
                self?.playlists = playlists
                completion(true)
            }
        }
    }
    
    func genreSorted() {
        
        var songs = [String: [Track]]()
        var tempArray = [Track]()
        
        for playlist in playlists {
            if let tracks = playlist.tracks {
                for track in tracks {
                    if let type = track.genre {
                        if type.isEmpty == false {
                            if let i = songs.keys.firstIndex(of: type) {
                                songs.values[i].append(track)
                                
                            } else {
                                tempArray.removeAll()
                                tempArray.append(track)
                                songs[type] = tempArray
                            }
                        }
                    }
                }
            }
        }
        self.songs = sortWithKeys(songs)
    }
    
    // Sort inputted dictionary with keys alphabetically.
    private func sortWithKeys(_ dict: [String: [Track]]) -> [String: [Track]] {
        
        let sorted = dict.sorted(by: { $0.key.prefix(1) < $1.key.prefix(1) })
        var newDict: [String: [Track]] = [:]
        
        for sortedDict in sorted {
            newDict[sortedDict.key] = sortedDict.value
        }
        
        return newDict
    }
}
