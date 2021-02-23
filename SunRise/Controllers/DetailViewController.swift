import UIKit

final class DetailViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupData() {
        
    }
    
    override func setupUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic-left-arrow-white"), style: .plain, target: self, action: #selector(popToLibraryViewController))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    @objc private func popToLibraryViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
