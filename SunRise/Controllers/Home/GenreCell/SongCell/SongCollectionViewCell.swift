import UIKit

final class SongCollectionViewCell: UICollectionViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak private var songImage: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func binding(track: Track) {
        titleLabel.text = track.title
        userLabel.text = track.userName
        
        track.artworkURL?.downloadImage() { [weak self]result in
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
