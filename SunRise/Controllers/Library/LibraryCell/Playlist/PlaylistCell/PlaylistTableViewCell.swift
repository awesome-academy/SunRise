import UIKit

final class PlaylistTableViewCell: UITableViewCell, Reusable, NibLoadable {

    @IBOutlet weak private var songImage: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userLabel: UILabel!
    @IBOutlet weak private var favoriteButton: UIButton!
    
    var isFavoriteButtonPressed: (() -> Void)?
    var isDetailButtonPressed: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        songImage.image = .none
        titleLabel.text = .none
        userLabel.text = .none
        favoriteButton.isSelected = true
    }
    
    // MARK: - Action
    
    @IBAction func detailPressed(sender: Any) {
        isDetailButtonPressed?()
    }
    
    @IBAction func favoritePressed(sender: Any) {
        isFavoriteButtonPressed?()
    }
    
    // MARK: - Config
    
    func binding(track: PlaylistManagedObject) {
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
}
