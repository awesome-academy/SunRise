import Foundation
import AVFoundation
import MediaPlayer
import UIKit

enum State {
    case isPlaying
    case stopped
}

final class Player {
    
    static let shared = Player()
    private var audioPlayer = AVPlayer()
    var songs = [String: [Track]]()
    var songPlayingID: Int?
    
    var state: State = .stopped {
        didSet {
            switch state {
            case .stopped:
                audioPlayer.pause()
            case .isPlaying:
                audioPlayer.volume = 1.0
                audioPlayer.play()
            }
        }
    }
    
    private init() {
        NotificationCenter.default.addObserver(self,
                                        selector: #selector(playerDidReachEnd),
                                        name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                        object: nil)

    }
    
    // MARK: - Play music
    
    func addSongPlayer(streamUrl: String?, completion: (Bool) -> Void) {
        if let streamUrl = streamUrl {
            let urlString = streamUrl + "?" + APIManager.APIRouter.client_path
            guard let url = URL(string: urlString) else {
                completion(false)
                return
            }
            audioPlayer = AVPlayer(url: url)
            completion(true)
        }
    }
    
    func playMusic(with track: Track) {
        addSongPlayer(streamUrl: track.streamURL) { done in
            if done {
                state = .isPlaying
                songPlayingID = track.trackID
                saveSongPlaying(with: track)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(playerDidReachEnd),
                                                       name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                       object: nil)
            }
        }
    }
    
    func playMusic(with track: FavoriteManagedObject) {
        addSongPlayer(streamUrl: track.streamURL) { done in
            if done {
                state = .isPlaying
                songPlayingID = Int(track.id)
                saveSongPlaying(with: track)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(playerDidReachEnd),
                                                       name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                       object: nil)
            }
        }
    }
    
    func playMusic(with track: PlaylistManagedObject) {
        addSongPlayer(streamUrl: track.streamURL) { done in
            if done {
                state = .isPlaying
                songPlayingID = Int(track.id)
                saveSongPlaying(with: track)
            }
        }
    }
    
    @objc func playerDidReachEnd() {
        audioPlayer.seek(to: .zero)
        state = .stopped
    }
    
    private func streamUrlPlaying() -> String? {
        if let url = ((audioPlayer.currentItem?.asset) as? AVURLAsset)?.url {

            let urlString = String(describing: url)

            let endOfSentence = urlString.firstIndex(of: "?") ?? urlString.endIndex
            let streamString = urlString[..<endOfSentence]
            return String(describing: streamString)
        }

        return nil
    }
    
    func getSecondCurrentTime() -> Double {
        return CMTimeGetSeconds(audioPlayer.currentItem?.currentTime() ?? CMTime())
    }
    
    func getSecondDuration() -> Double {
        return CMTimeGetSeconds(audioPlayer.currentItem?.duration ?? CMTime() )
    }
    
    func playAtRate(rate: Float) {
        let currentCMTime = CMTime(seconds: getSecondDuration() * Double(rate), preferredTimescale: .max)
        audioPlayer.seek(to: currentCMTime)
        state = .isPlaying
    }
    
    func autoPlayMusic() {
        if let track = songs.randomElement()?.value.randomElement() {
            playMusic(with: track)
        }
    }
    
    // MARK: - CoreData
    
    func fetchTrackPlaying() -> PlayingManagedObject?{
        if let playing = CoreDataManager.Playing.fetchData()?.first {
            
            if streamUrlPlaying() == nil {
                addSongPlayer(streamUrl: playing.streamURL,
                              completion: { _ in })
            }
            songPlayingID = Int(playing.id)
            return playing
        }
        return nil
    }
    
    func saveSongPlaying<T>(with track: T) {
        CoreDataManager.Playing.deleteAllObject()
        CoreDataManager.Playing.save(with: track)
    }
    
    func saveFavorite(id: Int?) {
        for (_, tracks) in songs {
            for track in tracks where track.trackID == id{
                CoreDataManager.Favorite.save(with: track)
                return
            }
        }
    }
    
    func removeFavorite(id: Int?) {
        for (_, tracks) in songs {
            for track in tracks where track.trackID == id {
                CoreDataManager.Favorite.remove(with: track.trackID ?? 0)
                return
            }
        }
    }
}
