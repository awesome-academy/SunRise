import UIKit

private enum HomeConstraints{
    static let heightForRowTableView: CGFloat = 300
}

final class HomeViewController: BaseViewController {

    @IBOutlet weak private var tableView: UITableView!
    
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
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
    }
    
    private func updateUI() {
        tableView.reloadData()
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
        return cell
    }
}
