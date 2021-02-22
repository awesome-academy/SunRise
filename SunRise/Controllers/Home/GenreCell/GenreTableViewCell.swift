import UIKit

final class GenreTableViewCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak private var genreLabel: UILabel!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    var isGenreCellPressed: ((Track) -> Void)?
    
    private var tracks = [Track]() {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(SongCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SongCollectionViewCell.reuseIdentifier)
    }

    override func setSelected(_ selected: Bool,
                          animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    func binding(genre: String,
               tracks: [Track]) {
        
        genreLabel.text = genre
        self.tracks = tracks
    }
    
    private func updateUI() {
        collectionView.reloadData()
        collectionView.contentOffset = .zero
    }
}

extension GenreTableViewCell: UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                    numberOfItemsInSection section: Int) -> Int {
        
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 160,
                    height: self.collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCollectionViewCell.reuseIdentifier,
                                                       for: indexPath) as? SongCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.binding(track: tracks[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        isGenreCellPressed?(tracks[indexPath.row])
    }
}
