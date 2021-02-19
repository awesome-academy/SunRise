import Foundation
import UIKit

extension String {
    func downloadImage(completion: @escaping APICompletion<UIImage?>) {
        API.shared.request(urlString: self) { result in
            switch result {
            case .failure(let error):
                completion(.failure(.error(error.localizedDescription)))
            case .success(let data):
                if let data = data {
                    completion(.success(UIImage(data: data) ?? nil))
                } else {
                    completion(.failure(.error("No data")))
                }
            }
        }
    }
}
