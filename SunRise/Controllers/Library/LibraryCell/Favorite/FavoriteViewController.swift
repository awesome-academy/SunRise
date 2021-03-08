import UIKit

private enum FavoriteConstraints {
    static let HeightForRowTableView: CGFloat = 160
}

final class FavoriteViewController: BaseViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userTitle: UILabel!
    
    private let viewModel = FavoriteViewModel()
    
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
        super.setupData()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteTableViewCell.nib,
                        forCellReuseIdentifier: FavoriteTableViewCell.reuseIdentifier)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.navigationItem.title = "Liked Songs"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic-left-arrow-white"), style: .plain, target: self, action: #selector(popToLibraryViewController))
        
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
            viewModel.removeFavorite(id: viewModel.songPlayingID)
        }
    }
    
    @IBAction func playerMusicPressed(sender: Any) {
        let vc = PlayerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.count
    }
    
    func tableView(_ tableView: UITableView,
                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.reuseIdentifier,
                                                 for: indexPath) as? FavoriteTableViewCell else { return FavoriteTableViewCell() }
        
        cell.selectionStyle = .none
        
        let item = viewModel.favorites[indexPath.row]
        cell.binding(track: item)
        
        cell.isFavoriteButtonPressed = { [weak self] in
            self?.viewModel.removeFavorite(id: Int(item.id))
            self?.updateData()
            self?.updateUI()
        }
        
        cell.isDetailButtonPressed = { [weak self] in
            self?.navigationController?.pushViewController(DetailViewController(favorites: item),
                                                  animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.favorites[indexPath.row]
        
        titleLabel.text = item.title
        userTitle.text = item.userName
        favoriteButton.isSelected = viewModel.isLiked(with: Int(item.id))
        playButton.isSelected = true
        
        viewModel.player.playMusic(with: item)

    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FavoriteConstraints.HeightForRowTableView
    }
}
