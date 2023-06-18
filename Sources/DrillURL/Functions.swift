//
//  File.swift
//  
//
//  Created by Michael on 6/17/23.
//

import Foundation

public extension DrillClient {
    
    func fetch<T:Decodable>(endpoint: String) async throws -> T {
        let url = try createURL(with: endpoint)
        return try await request(url: url)
    }
    
    func fetch<E:Encodable, D:Decodable>(_ parameters: E, endpoint: String) async throws -> D {
        let url = try createURL(with: parameters, endpoint: endpoint)
        return try await request(url: url)
    }
}
