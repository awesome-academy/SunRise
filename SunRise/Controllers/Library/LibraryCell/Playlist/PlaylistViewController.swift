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
    
    @IBAction func addSongsPressed(sender: Any) {
        
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
        
        let track = viewModel.playlists[indexPath.row]
        cell.binding(track: track)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaylistConstraints.heightForRowTableView
    }
}
