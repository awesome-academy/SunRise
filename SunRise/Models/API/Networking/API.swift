import Foundation

//MARK: -Defines

enum APIError: Error {
    case error(String)
    case errorURL
    
    var localizedDescription: String {
        switch self {
        case .error(let string):
            return string
        case .errorURL:
            return "URL string is error."
        }
    }
}

typealias APICompletion<T> = (Result<T, APIError>) -> Void

enum APIResult {
    case success(Data?)
    case failure(APIError)
}

//MARK: - API

struct API {
    
    static var shared: API {
        struct Static {
            static let instance = API()
        }
        return Static.instance
    }
    
    private init() {}
}
