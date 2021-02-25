import UIKit

private enum SearchConstraints{
    static let heightForRowResultSearchTableView: CGFloat = 160
    static let heightForRowHistoryTableView: CGFloat = 45
}

private enum TypeScreen {
    case history
    case resultSearch
    
    var heightForRowTableView: CGFloat {
        switch self {
        case .history:
            return SearchConstraints.heightForRowHistoryTableView
        case .resultSearch:
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
    
    private var viewModel = SearchViewModel()
    private var typeSreen: TypeScreen = .history
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
        
        tableView.register(SearchResultTableViewCell.nib,
                        forCellReuseIdentifier: SearchResultTableViewCell.reuseIdentifier)
        
        tableView.register(SearchHistoryTableViewCell.nib,
                        forCellReuseIdentifier: SearchHistoryTableViewCell.reuseIdentifier)
        
    }
    
    override func setupUI() {
        self.navigationController?.isNavigationBarHidden = true
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
    
    //MARK: - Private func
    
    private func scrollToTop() {
        let topRow = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: topRow,
                               at: .top,
                               animated: true)
    }
    
    // MARK: - Update
    
    private func updateData() {
        viewModel.fetchFavorite()
    }
    
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
    
    @IBAction func searching(sender: Any) {
        let text = searchTextField.text ?? ""
        
        if text.isEmpty {
            typeSreen = .history
        } else {
            viewModel.saveHistory(searchText: text)
            viewModel.getResultSearch(with: text) { [weak self]done in
                if done {
                    self?.typeSreen = .resultSearch
                    self?.updateUI()
                }
            }
        }
        updateUI()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch typeSreen {
        case .history:
            return viewModel.searchHistory.count
        case .resultSearch:
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
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        switch typeSreen {
        case .history:
            searchTextField.text = viewModel.searchHistory[indexPath.row]
        case .resultSearch:
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
                                  height: 35)
        
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
