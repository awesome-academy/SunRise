import Foundation
import AVFoundation
import NotificationCenter
import CoreData

final class HomeViewModel {
    
    private var playlists = [Playlist]()
    let player = Player.shared
    
    var songs = [String: [Track]]() {
        didSet {
            player.songs = songs
        }
    }
    
    var songPlayingID: Int?
    
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
    
    func saveFavorite() {
        player.saveFavorite(id: songPlayingID)
    }
    
    func removeFavorite() {
        player.removeFavorite(id: songPlayingID)
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
