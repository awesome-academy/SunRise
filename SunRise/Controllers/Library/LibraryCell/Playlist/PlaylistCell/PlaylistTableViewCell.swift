import UIKit

final class PlaylistTableViewCell: UITableViewCell, Reusable, NibLoadable {

    @IBOutlet weak private var songImage: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userLabel: UILabel!
    @IBOutlet weak private var favoriteButton: UIButton!
    
    var isFavoriteCellPressed: ((Bool) -> Void)?
    var isDetailCellPressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        favoriteButton.image = UIImage(named: "ic-heart-white")
        favoriteButton.selectedImage = UIImage(named: "ic-heart-green")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        songImage.image = UIImage(named: "ic-no-image-white")
        titleLabel.text = .none
        userLabel.text = .none
        favoriteButton.isSelected = false
    } 
    
    // MARK: - Action
    
    @IBAction func detailPressed(sender: Any) {
        isDetailCellPressed?()
    }
    
    @IBAction func favoritePressed(sender: Any) {
        favoriteButton.isSelected.toggle()
        isFavoriteCellPressed?(favoriteButton.isSelected)
    }
    
    // MARK: - Config
    
    func binding(track: PlaylistManagedObject, isLiked: Bool) {
        titleLabel.text = track.title ?? "Invalid"
        userLabel.text = track.userName ?? "Invalid"
        favoriteButton.isSelected = isLiked
        
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
