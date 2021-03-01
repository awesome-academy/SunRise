import UIKit

private enum LibraryConstraints{
    static let heightForRowTableView: CGFloat = 160
}

enum Type: Int {
    case createPlaylist = 0, favorite, playlist
}

final class LibraryViewController: BaseViewController {
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userTitle: UILabel!
    private let viewModel = LibraryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateData()
        updateUI()
    }
    
    // MARK: - Config
    
    override func setupData() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LibraryTableViewCell.nib, forCellReuseIdentifier: LibraryTableViewCell.reuseIdentifier)
    }
    
    override func setupUI() {
        self.navigationItem.title = "Library"
        
        favoriteButton.image = UIImage(named: "ic-heart-white")
        favoriteButton.selectedImage = UIImage(named: "ic-heart-green")
        
        playButton.image = UIImage(systemName: "play.fill")
        playButton.selectedImage = UIImage(systemName: "pause.fill")
    }
    
    // MARK: - Update
    
    private func updateData() {
        viewModel.fetchFavorite()
        viewModel.fetchPlaylist()
    }
    
    private func updateUI() {
        
        tableView.reloadData()
        
        switch Player.shared.state {
        case .isPlaying:
            playButton.isSelected = true
        case .stopped:
            playButton.isSelected = false
        }
        
        if let playing = viewModel.fetchTrackPlaying() {
            titleLabel.text = playing.title
            userTitle.text = playing.userName
            favoriteButton.isSelected = viewModel.isLiked(with: Int(playing.id))
        }
    }
    
    // MARK: - ACTION
    
    @IBAction func playPressed(sender: Any) {
        playButton.isSelected.toggle()
        
        viewModel.player.state = playButton.isSelected ? .isPlaying : .stopped
    }
    
    @IBAction func favoritePressed(sender: Any) {
        favoriteButton.isSelected.toggle()
        
        if favoriteButton.isSelected {
            viewModel.saveFavorite()
        } else {
            viewModel.removeFavorite()
        }
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return (2 + viewModel.playlists.keys.count)
    }
    
    func tableView(_ tableView: UITableView,
                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LibraryTableViewCell.reuseIdentifier,
                                                  for: indexPath) as? LibraryTableViewCell else { return LibraryTableViewCell() }
        cell.selectionStyle = .none
        
        let cellType = Type(rawValue: indexPath.row) ?? .playlist
        cell.binding(type: cellType,
                     playlistName: viewModel.playlistNames, at: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let cellType = Type(rawValue: indexPath.row) ?? .playlist
        switch cellType {
        case .createPlaylist:
            let vc = CreatePlaylistViewController()
            self.navigationController?.pushViewController( vc, animated: true)
        case .favorite:
            let vc = FavoriteViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .playlist:
            let key = viewModel.playlistNames[indexPath.row - 2]
            let playlists = viewModel.playlists[key] ?? [PlaylistManagedObject]()

            let vc = PlaylistViewController(playlists: playlists)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cellType = Type(rawValue: indexPath.row) ?? .playlist
        
        if cellType == .playlist {
            let delete = UIContextualAction(style: .destructive, title: "Delete") {  [weak self] (contextualAction, view, boolValue) in
                
                if let item = self?.viewModel.playlistNames[indexPath.row - 2] {
                    self?.viewModel.removePlaylist(name: item)
                }
                
                self?.tableView.reloadData()
            }
            let swipeActions = UISwipeActionsConfiguration(actions: [delete])
            
            return swipeActions
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LibraryConstraints.heightForRowTableView
    }
}
