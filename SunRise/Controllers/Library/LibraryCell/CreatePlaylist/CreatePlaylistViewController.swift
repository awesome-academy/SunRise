import UIKit

final class CreatePlaylistViewController: BaseViewController {
    
    @IBOutlet weak private var textField: UITextField!
    
    private let viewModel = CreatePlaylistViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func setupUI() {
        super.setupUI()
        self.navigationItem.title = "Give your playlist a name"
       
    }
    
    // MARK: - Action
    
    @IBAction func cancelPressed(sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func  okPressed(sender: Any) {
        viewModel.savePlaylistName(with: textField.text)
        self.navigationController?.popViewController(animated: true)
    }
}
