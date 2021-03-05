import UIKit

final class AddSongPlaylistViewController: BaseViewController {
    @IBOutlet weak private var tableView: UITableView!
    
    private let viewModel = AddSongPlaylistViewModel()
    var onPlaylistNameSelected: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupData() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        viewModel.fetchPlaylist()
    }

}

extension AddSongPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                  numberOfRowsInSection section: Int) -> Int {
        return viewModel.playlistNames.count
    }
    
    func tableView(_ tableView: UITableView,
                  cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = viewModel.playlistNames[indexPath.row]
        cell.textLabel?.text = item
        cell.backgroundColor = .clear
    
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                  didSelectRowAt indexPath: IndexPath) {
        
        let item = viewModel.playlistNames[indexPath.row]
        onPlaylistNameSelected?(item)
    }
}
