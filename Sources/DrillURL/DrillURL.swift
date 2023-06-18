
import Foundation
import os.log
import OSLog

public protocol DrillClient {
    var baseURL: String {get}
    func makeRequest(for url: URL) -> URLRequest
    
    var session: URLSession {get}
    var networkLogger: Logger { get }
    var log_level: [LogLevel] {get}

}

public extension DrillClient {
    var log_level: [LogLevel] { [.error, .request, .response] }
    var session: URLSession { URLSession.shared }

    var networkLogger: Logger {
        Logger(subsystem: "package.DrillURL.Client", category: "Networking")
    }
    var logger: Logger {
        networkLogger
    }
}
