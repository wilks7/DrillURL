//
//  File.swift
//  
//
//  Created by Michael on 6/17/23.
//

import Foundation

public extension DrillClient {
    
    func fetch<T:Decodable>(url: URL) async throws -> T {
        return try await request(url: url)
    }
    
    func fetch<E:Encodable, D:Decodable>(_ parameters: E, endpoint: String) async throws -> D {
        let url = try createURLEndpoint(with: parameters, endpoint: endpoint)
        return try await request(url: url)
    }
}
