//
//  File.swift
//  
//
//  Created by Michael on 6/18/23.
//

import Foundation

extension DrillClient {
    func decode<T:Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
    
            let dateFormatter = DateFormatter()
//            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    

            for dateFormat in DateFormats.allCases {
                dateFormatter.dateFormat = dateFormat.rawValue
                if let date = dateFormatter.date(from: dateStr) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot decode date string \(dateStr)")
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
