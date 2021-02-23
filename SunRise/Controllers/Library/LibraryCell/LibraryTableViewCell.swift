import UIKit

final class LibraryTableViewCell: UITableViewCell, Reusable, NibLoadable {

    @IBOutlet weak private var songImage: UIImageView!
    @IBOutlet weak private var playlistLabel: UILabel!
    @IBOutlet weak private var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        songImage.image = .none
        playlistLabel.text = .none
        userNameLabel.text = .none
    }
    
    func binding(type: Type) {
        switch type {
        case .createPlaylist:
            songImage.image = UIImage(systemName: "plus")
            playlistLabel.text = "Create Playlist"
        case .favorite:
            songImage.image = UIImage(named: "ic-heart-red")
            playlistLabel.text = "Liked Songs"
        default:
            break
        }
    }
}
