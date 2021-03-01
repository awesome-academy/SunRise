import UIKit

final class PlayerViewController: BaseViewController {
    
    @IBOutlet weak private var songImage: UIImageView!
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userTitle: UILabel!
    @IBOutlet weak private var slider: UISlider!

    private let viewModel = PlayerViewModel()
    weak private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateData()
        updateUI()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
        
        self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: - Config
    
    override func setupData() {
        super.setupData()
        
        NotificationCenter.default.addObserver(self,
                                           selector: #selector(playerDidReachEnd),
                                           name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                           object: nil)
    }
    
    @objc func updateSlider() {
        slider.setValue(viewModel.getRate(), animated: false)
    }
    
    override func setupUI() {
        super.setupUI()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic-left-arrow-white"), style: .plain, target: self, action: #selector(popToLibraryViewController))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        
        favoriteButton.image = UIImage(named: "ic-heart-white")
        favoriteButton.selectedImage = UIImage(named: "ic-heart-green")
        
        playButton.image = UIImage(named: "ic-media-play-white")
        playButton.selectedImage = UIImage(named: "ic-media-pause-white")
    }
    
    @objc private func popToLibraryViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func playerDidReachEnd() {
        playButton.isSelected = false
    }
    
    // MARK: - Update
    
    private func updateData() {
        viewModel.fetchFavorite()
    }
    
    private func updateUI() {
        switch Player.shared.state {
        case .isPlaying:
            playButton.isSelected = true
        case .stopped:
            playButton.isSelected = false
        }
        
        viewModel.fetchTrackPlaying() { done in
            let songPlaying = viewModel.songPlaying
            titleLabel.text = songPlaying.title
            userTitle.text = songPlaying.userName
            favoriteButton.isSelected = viewModel.isLiked(with: Int(songPlaying.id))
            
            songPlaying.artworkURL?.downloadImage() { [weak self] result in
                switch result {
                case .failure(_):
                    break
                case.success(let image):
                    self?.songImage.image = image
                }
            }
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
            viewModel.saveFavorite()
        } else {
            viewModel.removeFavorite()
        }
    }
    
    @IBAction func nextSongPressed(sender: Any) {
        viewModel.player.autoPlayMusic()
        updateData()
        updateUI()
    }
    
    @IBAction func backSongPressed(sender: Any) {
        viewModel.player.autoPlayMusic()
        updateData()
        updateUI()
    }
    
    @IBAction func sliderTouching(sender: UISlider) {
        playButton.isSelected = true
        viewModel.player.playAtRate(rate: sender.value)
    }
}
