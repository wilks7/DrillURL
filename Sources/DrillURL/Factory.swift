
import Foundation

extension DrillClient {
    
    public func createURL(with endpoint: String) throws -> URL {
        guard let url = URL(string: baseURL + endpoint) else {
            if log_level.contains(.error) {
                logger.error("Endpoint \(endpoint) couldn't cast to URL")
            }
            throw ClientError.endpoint(baseURL+endpoint)
        }
        return url
    }
}

extension DrillClient {
    
    func createURLEndpoint<T:Encodable>(with object: T, endpoint: String) throws -> URL {
        
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
