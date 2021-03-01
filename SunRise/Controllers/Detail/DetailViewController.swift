import UIKit

final class DetailViewController: BaseViewController {
    
    @IBOutlet weak private var songImage: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userLabel: UILabel!
    @IBOutlet weak private var favoriteButton: UIButton!
    
    private let viewModel: DetailViewModel
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Init
    
    init(favorites: FavoriteManagedObject) {
        self.viewModel = DetailViewModel(track: favorites)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    init(playlist: PlaylistManagedObject) {
        self.viewModel = DetailViewModel(track: playlist)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Config
    
    override func setupUI() {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic-left-arrow-white"), style: .plain, target: self, action: #selector(popToLibraryViewController))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        
        favoriteButton.image = UIImage(named: "ic-heart-white")
        favoriteButton.selectedImage = UIImage(named: "ic-heart-green")
        
        titleLabel.text = viewModel.getTitle()
        userLabel.text = viewModel.getUser()
        favoriteButton.isSelected = viewModel.isLiked()
        
        viewModel.getSongImage() { [weak self]result in
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
    
    @objc private func popToLibraryViewController() {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Action
    
    @IBAction func favoritePressed (sender: Any) {
        favoriteButton.isSelected.toggle()
        
        if favoriteButton.isSelected {
            viewModel.saveFavorite()
        } else {
            viewModel.removeFavorite()
        }
    }
    
    @IBAction func removePlaylistPressed (sender: Any) {
        viewModel.removeSongFromPlaylist()
    }
    
    @IBAction func addPlaylistPressed (sender: Any) {
        addToPlaylistAlert()
    }
    
    // MARK: Private Func
    private func addToPlaylistAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
           
        let contentViewController = AddSongPlaylistViewController()
        contentViewController.preferredContentSize = contentViewController.view.frame.size
        alertController.setValue(contentViewController, forKey: "contentViewController")
        alertController.view.backgroundColor = .white
    
        
        contentViewController.onPlaylistNameSelected = { [weak self] playlistName in
            self?.viewModel.playlistName = playlistName
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let playlistName = self?.viewModel.playlistName {
                self?.viewModel.addSongToPlaylist(name: playlistName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
