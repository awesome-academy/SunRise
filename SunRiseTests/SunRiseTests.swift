import Quick
import Nimble
@testable import SunRise

class SunRiseTests: QuickSpec {
    
    override func spec() {
        describe("Search view model") {
            let searchInputs = ["ffff", "rap"]
            var searchViewModel: SearchViewModel!
            var tracks: [Track]!
            
            beforeEach{
                searchViewModel = SearchViewModel()
                tracks = self.loadJson()
            }
            
            afterEach {
                searchViewModel = nil
                tracks = nil
            }
            
            context("History") {
                it("Save") {
                    searchViewModel.searchHistory.removeAll()
                    for searchInput in searchInputs {
                        searchViewModel.saveHistory(searchText: searchInput)
                        
                        expect(searchViewModel.searchHistory.contains(searchInput)).to(beTrue())
                    }
                    
                    searchViewModel.searchHistory.removeAll()
                    for searchInput in searchInputs {
                        searchViewModel.searchHistory.append(searchInput)
                        
                        expect(searchViewModel.searchHistory.contains(searchInput)).to(beTrue())
                    }
                }
                
                it("Repeat data") {
                    for searchInput in searchInputs {
                        searchViewModel.saveHistory(searchText: searchInput)
                        searchViewModel.saveHistory(searchText: searchInput)
                        
                        var counter: Int = 0
                        for item in searchViewModel.searchHistory where item == searchInput {
                            counter += 1
                        }
                        expect(counter).to(equal(1))
                    }
                }
                
                it("Delete") {
                    searchViewModel.searchHistory.removeAll()
                    
                    for searchInput in searchInputs {
                        expect(searchViewModel.searchHistory.contains(searchInput)).to(beFalse())
                    }
                }
            }
            
            context("Searching") {
                it("No Results") {
                    let searchInput = searchInputs[0]
                    
                    searchViewModel.getResultSearch(with: searchInput) { result in
                        expect(result).to(beFalse())
                    }
                }
                
                it("Have results") {
                    let searchInput = searchInputs[1]
                    
                    searchViewModel.getResultSearch(with: searchInput) { result in
                        expect(result).to(beTrue())
                    }
                }
                
                it("Delete tracks") {
                    if let track = tracks.first {
                        searchViewModel.tracks.append(track)
                        
                        searchViewModel.removeTrack(element: track)
                        expect(searchViewModel.tracks.firstIndex(where: { track in return false})).to(beNil())
                    }
                }
            }
            
            context("Song playing") {
                it("Save") {
                    if let track = tracks.randomElement() {
                        searchViewModel.saveSongPlaying(with: track)
                        let songPlaying = searchViewModel.fetchTrackPlaying()

                        expect(Int(songPlaying!.id)).to(equal(track.trackID))
                    }
                }
            }

            context("Favorite") {
                it("Save") {
                    searchViewModel.saveFavorite()
                    
                    if let songPlayingID = searchViewModel.fetchTrackPlaying()?.id {
                        let isLiked = searchViewModel.isLiked(with: Int(songPlayingID))
                        expect(isLiked).to(beTrue())
                    }
                }

                it("Remove") {
                    searchViewModel.removeFavorite()
                    
                    if let songPlayingID = searchViewModel.fetchTrackPlaying()?.id {
                        let isLiked = searchViewModel.isLiked(with: Int(songPlayingID))
                        expect(isLiked).to(beFalse())
                    }
                }
            }
        }
    }
    
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
