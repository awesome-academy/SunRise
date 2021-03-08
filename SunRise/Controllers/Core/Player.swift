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
    var songPlaying: PlayingManagedObject?
    
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
    
    // MARK: - Lock screen
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] event in
            if self?.audioPlayer.rate == 0.0 {
                self?.state = .isPlaying
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] event in
            if self?.audioPlayer.rate == 1.0 {
                self?.state = .stopped
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.autoPlayMusic()
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.autoPlayMusic()
            return .success
        }
    }
    
    func setupNowPlaying(title: String?, userName: String?, artworkURL: String?) {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        nowPlayingInfo[MPMediaItemPropertyArtist] = userName
        
        artworkURL?.downloadImage() { result in
            switch result {
            case .failure(_):
                break
            case .success(let image):
                if let image = image {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] =
                        MPMediaItemArtwork(boundsSize: CGSize(width: 45, height: 45)) { size in
                            return image
                    }
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        

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
                saveSongPlaying(with: track)
                setupNowPlaying(title: track.title, userName: track.userName, artworkURL: track.artworkURL)
            }
        }
    }
    
    func playMusic(with track: FavoriteManagedObject) {
        addSongPlayer(streamUrl: track.streamURL) { done in
            if done {
                state = .isPlaying
                saveSongPlaying(with: track)
                setupNowPlaying(title: track.title, userName: track.userName, artworkURL: track.artworkURL)
            }
        }
    }
    
    func playMusic(with track: PlaylistManagedObject) {
        addSongPlayer(streamUrl: track.streamURL) { done in
            if done {
                state = .isPlaying
                saveSongPlaying(with: track)
                setupNowPlaying(title: track.title, userName: track.userName, artworkURL: track.artworkURL)
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
            return playing
        }
        return nil
    }
    
    func saveSongPlaying<T>(with track: T) {
        CoreDataManager.Playing.deleteAllObject()
        CoreDataManager.Playing.save(with: track)
    }
    
    func saveFavorite() {
        if let songPlaying = fetchTrackPlaying() {
            CoreDataManager.Favorite.save(with: songPlaying)
        }
    }
    
    func removeFavorite() {
        if let songPlaying = fetchTrackPlaying() {
            CoreDataManager.Favorite.remove(with: Int(songPlaying.id))
        }
    }
}
