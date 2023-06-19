//
//  File.swift
//  
//
//  Created by Michael on 6/18/23.
//

import Foundation

public protocol DecodableDate: Decodable {
    static var dateFormat: String { get }
}

extension DrillClient {
    func decode<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        guard let type = T.self as? DecodableDate.Type else {
            return try decoder.decode(T.self, from: data)
        }

        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = type.dateFormat

            if let date = dateFormatter.date(from: dateStr) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
            }
        }

        return try decoder.decode(T.self, from: data)
    }

}


internal enum DateFormats: String, CaseIterable, Identifiable {
    var id: String {self.rawValue}
    case day = "yyyy-MM-dd"
    case month = "yyyy-MM"
    case year = "yyyy"
}
