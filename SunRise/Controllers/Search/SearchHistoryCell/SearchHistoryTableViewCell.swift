import UIKit

final class SearchHistoryTableViewCell: UITableViewCell, Reusable, NibLoadable {

    @IBOutlet weak private var historyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        historyLabel.text = .none
    }
    
    // MARK: - Config
    
    func binding(searchHistory: String) {
        historyLabel.text = searchHistory
    }
}
