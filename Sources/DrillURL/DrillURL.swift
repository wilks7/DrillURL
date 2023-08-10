
import Foundation
//import os.log
//import OSLog

public protocol DrillClient {
    var baseURL: String {get}
    func makeRequest(for url: URL) -> URLRequest
    
    var session: URLSession {get}
//    var network_logger: Logger { get }
    var log_level: [LogLevel] {get}

}

public class PrintLogger {
    func debug(_ string: String) {
        Swift.print(string)
    }
    
    func error(_ string: String) {
        Swift.print(string)
    }
}

public extension DrillClient {
        
    var log_level: [LogLevel] { [.error, .request, .response] }
    var session: URLSession { URLSession.shared }

    var network_logger: PrintLogger {
        PrintLogger()
//        Logger(subsystem: "package.DrillURL.Client", category: "Networking")
    }
    var logger: PrintLogger { network_logger }
}
