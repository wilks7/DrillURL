
import Foundation
import os.log
import OSLog

protocol Client {
    func makeRequest(for url: URL) -> URLRequest
    var session: URLSession {get}
    var baseURL: String {get}
    var networkLogger: Logger { get }
    var log_level: [LogLevel] {get}

}
extension Client {
    
    var logger: Logger {
        Logger(subsystem: "package.DrillURL.Client", category: "Networking")
    }
    
    func fetch<T:Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            if log_level.contains(.error) {
                logger.error("Endpoint \(endpoint) couldn't cast to URL")
            }
            throw ClientError.endpoint(baseURL+endpoint)
        }
        return try await request(url: url)
    }
    
    func fetch<E:Encodable, D:Decodable>(_ parameters: E, endpoint: String) async throws -> D {
        let url = try createURL(with: parameters, endpoint: endpoint)
        return try await request(url: url)
    }
}

extension Client {
    var session: URLSession { URLSession.shared }
    
    private func createURL<T:Encodable>(with object: T, endpoint: String) throws -> URL {
        
        let endpoint = baseURL + endpoint
        guard var components = URLComponents(string: endpoint) else {
            if log_level.contains(.error) {
                logger.error("URL Components \(endpoint) couldn't cast to URL")
            }
            throw ClientError.endpoint(endpoint)
        }
        
        let queryParameters: [URLQueryItem]
        do {
            queryParameters = try QueryEncoder().encode(object)
        } catch {
            if log_level.contains(.error) {
                logger.error("QueryEncoder couldn't encode parameters for \(String(describing: T.self))")
            }
            throw error
        }
        
        components.queryItems = queryParameters
            .filter { $0.value != "" }
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        if let url = components.url {
            return url
        } else {
            if log_level.contains(.error) {
                logger.error("URL Components \(endpoint) couldn't cast to URL")
            }
            throw ClientError.endpoint(endpoint)
        }
        
    }

    private func request<T: Decodable>(url: URL) async throws -> T {
        let request = makeRequest(for: url)
        
        if log_level.contains(.request) {
            logger.debug("Fetching \(url.absoluteString)")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResonse = response as? HTTPURLResponse else {
            if log_level.contains(.error) {
                logger.error("Bad HTTP Response: \(url.absoluteString)")
                json(print: data)
            }
            throw ClientError.statusCode(-1, "Bad HTTP Response")
        }
        
        guard (200 ..< 300) ~= httpResonse.statusCode else {
            let statusCode = httpResonse.statusCode
            if log_level.contains(.error) {
                logger.error("Status Code: \(statusCode) for \(url.absoluteString)")
                json(print: data)
            }
            throw ClientError.statusCode(statusCode, url.absoluteString)
        }
        if log_level.contains(.response) {
            json(print: data)
        }
        do {
            let object: T = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            if log_level.contains(.error) {
                logger.error("Decode error for \(String(describing: T.self))")
                json(print: data)
            }
            throw ClientError.decode(T.self)
        }
    }
    
    private func json(print data: Data) {
        if let nsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            Swift.print(nsString)
        } else {
            Swift.print("Data doesn't represent a valid JSON structure.")
        }
    }
}
struct QueryEncoder {
    func encode<E: Encodable>(_ object: E) throws -> [URLQueryItem] {
        let data = try JSONEncoder().encode(object)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = jsonObject as? [String: Any] else {
            throw ClientError.encode(E.self)
        }
        return dictionary.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
    }
}

enum ClientError: Swift.Error{
    case encode(Encodable.Type)
    case decode(Decodable.Type)
    case statusCode(Int, String)
    case message(String)
    case endpoint(String)
    
    var message: String {
        switch self {
        case .decode(let decodable):
            let object = String(describing: decodable)
            return object + "could not be decoded"
        case .statusCode(let int, let string):
            return int.description + ": " + string
        case .message(let string):
            return string
        case .endpoint(let string):
            return string
        case .encode(let encodeable):
            return String(describing: encodeable)
        }
    }
}


