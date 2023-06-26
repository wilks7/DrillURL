
import Foundation

extension DrillClient {
    /// This function takes an endpoint string and returns a URL by appending the endpoint to the base URL.
    /// - Parameter endpoint: The endpoint string to be appended to the base URL.
    /// - Throws: `ClientError.endpoint` if the endpoint string couldn't be cast to URL.
    /// - Returns: A URL by appending the endpoint to the base URL.
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
    
    /// This function creates a URL endpoint with an object conforming to the Encodable protocol and a string endpoint.
    /// - Parameters:
    ///   - object: An object conforming to the Encodable protocol.
    ///   - endpoint: A string endpoint.
    /// - Returns: A URL endpoint.
    /// - Throws: A ClientError if the endpoint couldn't cast to URL or if the QueryEncoder couldn't encode parameters.
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
