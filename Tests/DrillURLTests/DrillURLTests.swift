import XCTest
@testable import DrillURL
import Foundation

final class DrillURLTests: XCTestCase {
    
    class Client: DrillClient {
        
        let baseURL: String = "https://api.setlist.fm/rest/1.0/"
        let apiKey: String = "YAuLpSRz4LjQmUgE7lst6ZTkS028LwOelLS9"
        
        func makeRequest(for url: URL) -> URLRequest {
            var request = URLRequest(url: url)
            
            request.httpMethod = "GET"
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            return request
        }
        
        struct Artist: Decodable {
            let mbid: String
            let name: String
        }
        
        struct ArtistRequest: Encodable {
            let artistMbid: String
            var p: Int = 1
        }
        
        struct ArtistResult: Decodable {
            let page: Int
            let artist: [Artist]
        }
    }
    
    let client = Client()
    
    func testEndpoint() async {
        do {
            let phish = "e01646f2-2a04-450d-8bf2-0d993082e058"
            let endpoint = "artist/\(phish)"
            let url = URL(string: client.baseURL + endpoint)!
            let artist: Client.Artist = try await Client().fetch(url: url)
            XCTAssertEqual(artist.mbid, phish, "Artist data contains the correct id")
        } catch {
            XCTFail("Failed to fetch artist: \(error)")
        }
    }
    
    func testRequest() async {
        do {
            let phish = "e01646f2-2a04-450d-8bf2-0d993082e058"
            let endpoint = "search/artists"
            
            let request: Client.ArtistRequest = .init(artistMbid: phish)
            
            let result: Client.ArtistResult = try await Client().fetch(request, endpoint: endpoint)
            XCTAssertEqual(result.page, 1, "Result data is first page")
        } catch {
            XCTFail("Failed to fetch artist: \(error)")
        }
    }
}
