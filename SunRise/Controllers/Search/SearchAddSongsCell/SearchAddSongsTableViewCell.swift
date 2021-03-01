import UIKit

final class SearchAddSongsTableViewCell: UITableViewCell, Reusable, NibLoadable {

    @IBOutlet weak private var songImage: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userLabel: UILabel!
    @IBOutlet weak private var addSongButton: UIButton!
    
    private var track: Track?
    var isAddButtonPressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        songImage.image = .none
        titleLabel.text = .none
        userLabel.text = .none
        addSongButton.isUserInteractionEnabled = true
    }
    
    // MARK: - Config
    
    func binding(track: Track) {
        self.track = track
        
        titleLabel.text = track.title
        userLabel.text = track.userName
        
        track.artworkURL?.downloadImage() { [weak self] result in
            switch result {
            case .failure(_):
                break
            case .success(let image):
                if let image = image {
                    self?.songImage.image = image
                }
            }
        }
    }
    
    // MARK: - Private func
    
    private func pushAddSongNotificaiton(track: Track) {
        let notification = Notification(name: .addSongsPlaylist,
                                       object: track, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    // MARK: Action
    
    @IBAction func addSongToPlaylistPressed(sender: Any) {
        isAddButtonPressed?()
        addSongButton.isUserInteractionEnabled = false
        if let track = track {
            pushAddSongNotificaiton(track: track)
        }

    }
}
