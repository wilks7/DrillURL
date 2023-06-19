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
    
            let dateFormats = ["yyyy-MM-dd", "MM/dd/yyyy", "yyyyMMdd"]

            for dateFormat in dateFormats {
                dateFormatter.dateFormat = dateFormat
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
