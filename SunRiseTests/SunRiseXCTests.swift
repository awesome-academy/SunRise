import XCTest
@testable import SunRise

class SunRiseXCTests: XCTestCase {
    let searchInputs = ["ffff", "rap"]
    var searchViewModel: SearchViewModel!
    var tracks: [Track]!
    
    override func setUp() {
        super.setUp()
        searchViewModel = SearchViewModel()
        tracks = loadJson()
    }
    
    override func tearDown() {
        super.tearDown()
        searchViewModel = nil
        tracks = nil
    }
    
    // MARK: - History
    
    func testSaveHistory() {
        searchViewModel.searchHistory.removeAll()
        for searchInput in searchInputs {
            searchViewModel.saveHistory(searchText: searchInput)
            
            XCTAssertTrue(searchViewModel.searchHistory.contains(searchInput))
        }
        
        searchViewModel.searchHistory.removeAll()
        for searchInput in searchInputs {
            searchViewModel.searchHistory.append(searchInput)
            
            XCTAssertTrue(searchViewModel.searchHistory.contains(searchInput))
        }
    }
    
    func testRepeatSearchInput() {
        for searchInput in searchInputs {
            searchViewModel.saveHistory(searchText: searchInput)
            searchViewModel.saveHistory(searchText: searchInput)
            
            var counter: Int = 0
            for item in searchViewModel.searchHistory where item == searchInput {
                counter += 1
            }
            
            XCTAssertEqual(counter, Int(1))
        }
    }
    
    func testDeleteHistory() {
        searchViewModel.searchHistory.removeAll()
        
        for searchInput in searchInputs {
            XCTAssertFalse(searchViewModel.searchHistory.contains(searchInput))
        }
    }
    
    // MARK: - Searching
    
    func tesetNoResultsSearching() {
        let searchInput = searchInputs[0]
        
        searchViewModel.getResultSearch(with: searchInput) { result in
            XCTAssertFalse(result)
        }
    }
    
    func testHaveResultsSearching() {
        let searchInput = searchInputs[1]
        
        searchViewModel.getResultSearch(with: searchInput) { result in
            XCTAssertTrue(result)
        }
    }
    
    func testDeleteTracks() {
        if let track = tracks.first {
            searchViewModel.tracks.append(track)
            
            searchViewModel.removeTrack(element: track)
            XCTAssertNil(searchViewModel.tracks.firstIndex(where: { track in return false}))
        }
    }
    
    func testSaveSongPlaying() {
        if let track = tracks.randomElement() {
            searchViewModel.saveSongPlaying(with: track)
            let songPlaying = searchViewModel.fetchTrackPlaying()

            XCTAssertEqual(Int(songPlaying!.id), track.trackID)
        }
    }
    
    // MARK: Favorites
    
    func testSaveFavorite() {
        searchViewModel.saveFavorite()
        
        if let songPlayingID = searchViewModel.fetchTrackPlaying()?.id {
            let isLiked = searchViewModel.isLiked(with: Int(songPlayingID))
            XCTAssertTrue(isLiked)
        }
    }
    
    func testRemoveFavorite() {
        searchViewModel.removeFavorite()
        
        if let songPlayingID = searchViewModel.fetchTrackPlaying()?.id {
            let isLiked = searchViewModel.isLiked(with: Int(songPlayingID))
            XCTAssertFalse(isLiked)
        }
    }
    
    // MARK: Moc data
    
    func loadJson() -> [Track]?{
        let path = Bundle.main.path(forResource: "content", ofType: "json")!
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let playlists = try! JSONDecoder().decode([Playlist].self, from: data)
            return playlists.first?.tracks
        } catch {
            print("Load json error: \(error)")
        }
        return nil
    }
}
