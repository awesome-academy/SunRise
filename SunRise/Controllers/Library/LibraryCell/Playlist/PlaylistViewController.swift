import UIKit

private enum PlaylistConstraints{
    static let heightForRowTableView: CGFloat = 160
}

final class PlaylistViewController: BaseViewController {
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userTitle: UILabel!
    
    private var viewModel: PlaylistViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateData()
        updateUI()
    }
    
    init(playlists: [PlaylistManagedObject]) {
        self.viewModel = PlaylistViewModel(playlists: playlists)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Config
    
    override func setupData() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PlaylistTableViewCell.nib, forCellReuseIdentifier: PlaylistTableViewCell.reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAddSongNotification(notification:)), name: .addSongsPlaylist, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRemoveSongNotification), name: .removeSongPlaylist, object: nil)
        
    }
    
    override func setupUI() {
        self.navigationItem.title = viewModel.playlists.first?.playlistName
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic-left-arrow-white"), style: .plain, target: self, action: #selector(popToLibraryViewController))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        
        favoriteButton.image = UIImage(named: "ic-heart-white")
        favoriteButton.selectedImage = UIImage(named: "ic-heart-green")
        
        playButton.image = UIImage(systemName: "play.fill")
        playButton.selectedImage = UIImage(systemName: "pause.fill")
    }
    
    @objc private func popToLibraryViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Update
    
    private func updateData() {
        viewModel.fetchFavorite()
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
    
    @objc func handleAddSongNotification(notification: Notification) {
        if let track = notification.object as? Track {
            viewModel.addSongToPlaylist(with: track)
            viewModel.fetchPlaylist()
        }
    }
    
    @objc func handleRemoveSongNotification (notification: Notification) {
        if let track = notification.object as? PlaylistManagedObject {
            viewModel.removeTrackPlaylist(element: track)
            viewModel.fetchPlaylist()
        }
    }
    
    // MARK: - ACTION
    
    @IBAction func playPlayerPressed(sender: Any) {
        playButton.isSelected.toggle()
        
        viewModel.player.state = playButton.isSelected ? .isPlaying : .stopped
    }
    
    @IBAction func favoritePlayerPressed(sender: Any) {
        favoriteButton.isSelected.toggle()
        
        if favoriteButton.isSelected {
            viewModel.player.saveFavorite(id: viewModel.player.songPlayingID)
        } else {
            viewModel.player.removeFavorite(id: viewModel.player.songPlayingID)
        }
    }
    
    @IBAction func addSongsPressed(sender: Any) {
        self.navigationController?.pushViewController(SearchViewController(), animated: true)
    }
    
    @IBAction func playerMusicPressed(sender: Any) {
        let vc = PlayerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.playlists.count - 1
    }
    
    func tableView(_ tableView: UITableView,
                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.reuseIdentifier,
                                                  for: indexPath) as? PlaylistTableViewCell else { return PlaylistTableViewCell() }
        cell.selectionStyle = .none
        
        let item = viewModel.playlists[indexPath.row]
        let isliked = viewModel.isLiked(with: Int(item.id))
        cell.binding(track: item, isLiked: isliked)
        
        cell.isFavoriteCellPressed = { [weak self] isLiked in
            if isLiked {
                self?.viewModel.saveFavorite(track: item)
            } else {
                self?.viewModel.removeFavorite(track: item)
            }
            self?.updateData()
            self?.updateUI()
        }
        
        cell.isDetailCellPressed = { [weak self] in
            self?.navigationController?.pushViewController(DetailViewController(playlist: item),
                                                  animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.playlists[indexPath.row]
        
        titleLabel.text = item.title
        userTitle.text = item.userName
        favoriteButton.isSelected = viewModel.isLiked(with: Int(item.id))
        playButton.isSelected = true
        
        viewModel.player.playMusic(with: item)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive,
                                    title: "Delete") {  [weak self] (contextualAction, view, boolValue) in
            
            if let item = self?.viewModel.playlists[indexPath.row] {
                self?.viewModel.removeTrackPlaylist(element: item)
            }
            
            self?.tableView.reloadData()
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [delete])

        return swipeActions
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaylistConstraints.heightForRowTableView
    }
}
