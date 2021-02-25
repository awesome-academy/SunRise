import Foundation

extension APIManager.Music {
    
    enum QueryString {
        static let playlist = APIManager.APIRouter.playlists_path
                                        + "?"
                                        + APIManager.APIRouter.client_path
    }
    
    static func getPlaylist(completion: @escaping APICompletion<[Playlist]>) {
        
        let urlString = QueryString.playlist
        
        API.shared.request(urlString: urlString) { result -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                if let data = data {
                    do {
                        let playlists = try JSONDecoder().decode([Playlist].self, from: data)
                        completion(.success(playlists))
                    } catch {
                        completion(.failure(.error(error.localizedDescription)))
                    }
                }
            }
        }
    }
    
    static func getResultSearch(with searchText: String, completion: @escaping APICompletion<[Track]>) {
        
        let urlString = APIManager.APIRouter.search_tracks_path + searchText + "&" + APIManager.APIRouter.client_path
        
        API.shared.request(urlString: urlString) { result -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                if let data = data {
                    do {
                        let tracks = try JSONDecoder().decode([Track].self, from: data)
                        completion(.success(tracks))
                    } catch {
                        completion(.failure(.error(error.localizedDescription)))
                    }
                }
            }
        }
    }
}
