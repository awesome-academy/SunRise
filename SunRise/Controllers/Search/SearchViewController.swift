import UIKit
import NotificationCenter

private enum SearchConstraints{
    static let heightForRowResultSearchTableView: CGFloat = 160
    static let heightForRowHistoryTableView: CGFloat = 45
    static let heightForFooterTableView: CGFloat = 35
}

private enum TypeScreen {
    case history
    case resultSearch
    case resultAddSongs
    case noResultsFound
    
    var heightForRowTableView: CGFloat {
        switch self {
        case .history:
            return SearchConstraints.heightForRowHistoryTableView
        default:
            return SearchConstraints.heightForRowResultSearchTableView
            
        }
    }
}

final class SearchViewController: BaseViewController {
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var userTitle: UILabel!
    @IBOutlet weak private var searchTextField: UITextField!
    @IBOutlet weak private var noReultsImage: UIImageView!
    
    private var viewModel = SearchViewModel()
    private var typeScreenInit: TypeScreen?
    private var typeSreen: TypeScreen = .history {
        didSet {
            switch typeSreen {
            case .noResultsFound:
                tableView.alpha = 0
                noReultsImage.alpha = 1
            default:
                tableView.alpha = 1
                noReultsImage.alpha = 0
            }
        }
    }
    private var playlistNameToAdd: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    // MARK: - Config
    
    override func setupData() {
        super.setupData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SearchResultTableViewCell.nib,
                        forCellReuseIdentifier: SearchResultTableViewCell.reuseIdentifier)
        
        tableView.register(SearchHistoryTableViewCell.nib,
                        forCellReuseIdentifier: SearchHistoryTableViewCell.reuseIdentifier)
        
        tableView.register(SearchAddSongsTableViewCell.nib,
                        forCellReuseIdentifier: SearchAddSongsTableViewCell.reuseIdentifier)  
    }
    
    override func setupUI() {
        super.setupUI()
        
        if self.navigationController?.getPreviousViewController() == self.navigationController?.presentedViewController {
            typeScreenInit = .resultSearch
            typeSreen = .history
            self.navigationController?.isNavigationBarHidden = true
        } else {
            typeScreenInit = .resultAddSongs
            typeSreen = .resultAddSongs
            self.navigationItem.title = "Add songs"
            self.navigationController?.isNavigationBarHidden = false
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic-left-arrow-white"), style: .plain, target: self, action: #selector(popToLibraryViewController))
        self.hideKeyboardWhenTappedAround()
        
        favoriteButton.image = UIImage(named: "ic-heart-white")
        favoriteButton.selectedImage = UIImage(named: "ic-heart-green")
        
        playButton.image = UIImage(systemName: "play.fill")
        playButton.selectedImage = UIImage(systemName: "pause.fill")
        
        noReultsImage.alpha = 0
    }
    
    @objc private func popToLibraryViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Private func
    
    private func scrollToTop() {
        let topRow = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: topRow,
                               at: .top,
                               animated: true)
    }
    
    // MARK: - Update
    
    private func updateUI() {
        if(tableView.numberOfRows(inSection: 0) != 0 ) {
            scrollToTop()
        }
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
    
    @IBAction func searchingEditingChanged(send: Any) {
        typeSreen = .history
    }
    
    @IBAction func searching(sender: Any) {
        let text = searchTextField.text ?? ""
        
        if text.isEmpty {
            typeSreen = .history
        } else {
            viewModel.saveHistory(searchText: text)
            viewModel.getResultSearch(with: text) { [weak self]done in
                if done {
                    self?.typeSreen = self?.typeScreenInit ?? .resultSearch
                    self?.updateUI()
                } else {
                    self?.typeSreen = .noResultsFound
                }
            }
        }
        updateUI()
    }
    
    @IBAction func playerMusicPressed(sender: Any) {
        let vc = PlayerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch typeSreen {
        case .history:
            return viewModel.searchHistory.count
        default:
            return viewModel.tracks.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch typeSreen {
        case .history:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.reuseIdentifier,
                                                      for: indexPath) as? SearchHistoryTableViewCell else { return SearchHistoryTableViewCell() }
            cell.selectionStyle = .none
            cell.binding(searchHistory: viewModel.searchHistory[indexPath.row])
            return cell
        case .resultSearch:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.reuseIdentifier,
                                                      for: indexPath) as? SearchResultTableViewCell else { return SearchResultTableViewCell() }
            cell.selectionStyle = .none
            
            let track = viewModel.tracks[indexPath.row]
            cell.binding(track: track)
            return cell
        case .resultAddSongs:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAddSongsTableViewCell.reuseIdentifier,
                                                      for: indexPath) as? SearchAddSongsTableViewCell else { return SearchAddSongsTableViewCell() }
            cell.selectionStyle = .none
            
            let track = viewModel.tracks[indexPath.row]
            cell.binding(track: track)
            
            cell.isAddButtonPressed = { [weak self] in
                self?.viewModel.removeTrack(element: track)
                self?.tableView.reloadData()
            }
            return cell
        case .noResultsFound:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        switch typeSreen {
        case .history:
            searchTextField.text = viewModel.searchHistory[indexPath.row]
        default:
            let item = viewModel.tracks[indexPath.row]
            
            titleLabel.text = item.title
            userTitle.text = item.userName
            if let id = item.trackID {
                favoriteButton.isSelected = viewModel.isLiked(with: id)
            }
            playButton.isSelected = true
            
            viewModel.player.playMusic(with: item)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .black
        footerView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: self.view.frame.width,
                                  height: SearchConstraints.heightForFooterTableView)
        
        let button = UIButton()
        button.frame = footerView.frame
        button.setTitle("Clear recent searches", for: .normal)
        button.setTitleColor(.systemGray6, for: .normal)
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .left
        button.addAction(.init(handler: { [weak self]_ in
            self?.viewModel.searchHistory.removeAll()
            self?.updateUI()
        }), for: .touchUpInside)
        
        footerView.addSubview(button)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return typeSreen.heightForRowTableView
    }
}
