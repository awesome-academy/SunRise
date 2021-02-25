import Foundation
import UIKit

struct Track: Codable {
    
    let trackID: Int?
    let title: String?
    let genre: String?
    let streamURL: String?
    let artworkURL: String?
    
    let userID: Int?
    let userName: String?

    enum SongKeys: String, CodingKey {
        case trackID = "id"
        case title
        case userName = "user"
        case genre
        case streamURL = "stream_url"
        case artworkURL = "artwork_url"
    }

    enum UserKeys: String, CodingKey {
        case userID = "id"
        case userName = "username"
    }

    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: SongKeys.self)

        trackID = try container.decode(Int.self, forKey: .trackID)
        title = try container.decode(String.self, forKey: .title)
        genre = try container.decode(String.self, forKey: .genre)
        streamURL = try container.decode(String.self, forKey: .streamURL)
        artworkURL = try container.decode(String.self, forKey: .artworkURL)

        let user = try container.nestedContainer(keyedBy: UserKeys.self, forKey: .userName)

        userID = try user.decode(Int.self, forKey: .userID)
        userName = try user.decode(String.self, forKey: .userName)
    }
}
