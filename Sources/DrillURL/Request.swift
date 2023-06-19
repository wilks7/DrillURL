//
//  File.swift
//  
//
//  Created by Michael on 6/17/23.
//

import Foundation

extension DrillClient {

    func request<T: Decodable>(url: URL) async throws -> T {
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
            return try decode(data: data)
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
