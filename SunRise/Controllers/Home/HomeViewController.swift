import UIKit
import AVFoundation

private enum HomeConstraints{
    static let heightForRowTableView: CGFloat = 300
}

final class HomeViewController: BaseViewController {

    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userTitle: UILabel!
    
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    // MARK: - Config
    
    override func setupData() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(GenreTableViewCell.nib,
                           forCellReuseIdentifier: GenreTableViewCell.reuseIdentifier)
        
        viewModel.loadAPI() { [weak self]done in
            if done {
                self?.viewModel.genreSorted()
                self?.updateUI()
            }
        }
        
        if let playing = viewModel.player.fetchTrackPlaying() {
            titleLabel.text = playing.title
            userTitle.text = playing.userName
            favoriteButton.isSelected = viewModel.isLiked(with: Int(playing.id))
        }
    }
    
    override func setupUI() {
        favoriteButton.image = UIImage(named: "ic-heart-white")
        favoriteButton.selectedImage = UIImage(named: "ic-heart-green")
        
        playButton.image = UIImage(systemName: "play.fill")
        playButton.selectedImage = UIImage(systemName: "pause.fill")
    }
    
    private func updateUI() {
        
        tableView.reloadData()
        
        switch viewModel.player.state {
        case .isPlaying:
            playButton.isSelected = true
        case .stopped:
            playButton.isSelected = false
        }
        
        if let playing = viewModel.player.fetchTrackPlaying() {
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
    
    @IBAction func playerMusicPressed(sender: Any) {
        let vc = PlayerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate,
                         UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                numberOfRowsInSection section: Int) -> Int {
        return viewModel.songs.keys.count
    }
    
    func tableView(_ tableView: UITableView,
                heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeConstraints.heightForRowTableView
    }
    
    func tableView(_ tableView: UITableView,
                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GenreTableViewCell.reuseIdentifier,
                                                  for: indexPath) as? GenreTableViewCell
        else { return UITableViewCell() }
        
        let song = viewModel.songs
        let type = Array(song.keys)[indexPath.row]
        
        cell.binding(genre: type,
                    tracks: song[type] ?? [Track]())
        
        cell.isGenreCellPressed = { [weak self] track in
            self?.titleLabel.text = track.title
            self?.userTitle.text = track.userName
            
            if let isLiked = self?.viewModel.isLiked(with: track.trackID ?? 0) {
                self?.favoriteButton.isSelected = isLiked
            }
            
            self?.playButton.isSelected = true
            
            self?.viewModel.player.playMusic(with: track)
        }
        return cell
    }
}
