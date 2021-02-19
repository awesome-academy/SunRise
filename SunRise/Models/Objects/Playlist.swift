import Foundation
import UIKit

struct Playlist: Codable {

    let tracks: [Track]?

    enum PlaylistKeys: String, CodingKey {
        case tracks = "tracks"
    }

    init(from decoder: Decoder) throws{
        do {
            let container = try decoder.container(keyedBy: PlaylistKeys.self)
            tracks = try container.decode([Track].self, forKey: .tracks)
        } catch {
            self.tracks = nil
        }

    }
}
