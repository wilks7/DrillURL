import XCTest
@testable import DrillURL
import Foundation

final class DrillURLTests: XCTestCase {
    
    class Client: DrillClient {
        
        let baseURL: String = "https://api.setlist.fm/rest/1.0/"
        let apiKey: String = ""
        
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
    }
    
    func testExample() async {
        do {
            let phish = "e01646f2-2a04-450d-8bf2-0d993082e058"
            let endpoint = "artist/\(phish)"
            let artist: Client.Artist = try await Client().fetch(endpoint: endpoint)
            XCTAssertEqual(artist.mbid, phish, "Artist data contains the correct id")
        } catch {
            XCTFail("Failed to fetch artist: \(error)")
        }
    }
}
