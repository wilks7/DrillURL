//
//  File.swift
//  
//
//  Created by Michael on 6/17/23.
//

import Foundation

public extension DrillClient {
    
    
    /// This function takes an endpoint string and returns a URL by appending the endpoint to the base URL.
    
    func fetch<T:Decodable>(endpoint: String) async throws -> T {
        let url = try createURL(with: endpoint)
        return try await request(url: url)
    }
    
    func fetch<T:Decodable>(url: URL) async throws -> T {
        return try await request(url: url)
    }
    
    func fetch<E:Encodable, D:Decodable>(_ parameters: E, endpoint: String) async throws -> D {
        let url = try createURLEndpoint(with: parameters, endpoint: endpoint)
        return try await request(url: url)
    }
}
