//
//  File.swift
//  
//
//  Created by Michael on 6/17/23.
//

import Foundation

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
