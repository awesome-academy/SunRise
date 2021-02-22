import UIKit

extension UIButton {
    
    public var image: UIImage? {
        get { return self.image(for: .normal) }
        set {
            setImage(newValue, for: .normal)
        }
    }
    
    public var selectedImage: UIImage? {
        get { return self.image(for: .selected) }
        set {
            setImage(newValue, for: .selected)
        }
    }
}
