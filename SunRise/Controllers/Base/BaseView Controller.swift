import Foundation
import UIKit

class BaseViewController: UIViewController, UITabBarDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupUI()
    }
    
    func setupData() {
        
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.tintColor = .white
    }
}
