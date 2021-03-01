import UIKit

extension UINavigationController {
    func getPreviousViewController() -> UIViewController? {
        let count = viewControllers.count
        guard count > 1 else { return nil }
        return viewControllers[count - 2]
    }
}
