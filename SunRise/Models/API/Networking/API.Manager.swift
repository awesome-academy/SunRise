import Foundation

struct APIManager {
    
    enum APIRouter {
        private static let base_domain = "http://api.soundcloud.com"
        static let playlists_path = base_domain + "/playlists"
        static let tracks_path = base_domain + "/tracks"
        static let user_path = base_domain + "/users"
        static let stream_path = "/stream"
        static let client_path = "client_id=" + APIManager.APIKey.ClientID
    }
    
    struct Music {}
}
