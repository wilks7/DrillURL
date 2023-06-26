
import Foundation

public protocol DateValueStrategy {
    static func decode(_ value: String?) throws -> Date?
    static func encode(_ date: Date?) -> String?
}

/// Uses a format to decode a date from Codable.
@propertyWrapper public struct DateFormatted<T: DateValueStrategy>: Codable {
    public let value: String?
    public var wrappedValue: Date?

    // For non-optional Date
    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
        self.value = T.encode(wrappedValue)
    }

    // For optional Date
    public init(wrappedValue: Date?) {
        
        self.wrappedValue = wrappedValue
        self.value = wrappedValue == nil ? nil : T.encode(wrappedValue!)
    }
    
    public init(from decoder: Decoder) throws {
        self.value = try? String(from: decoder)
        self.wrappedValue = try? T.decode(value)
    }
    
    public func encode(to encoder: Encoder) throws {
        try? value.encode(to: encoder)
    }
}

public enum DateStrategyError: Swift.Error {
    case decode
}


public struct FMSetlistDateStrategy: DateValueStrategy {

    public static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    public static func decode(_ value: String?) throws -> Date? {
        guard let value else {return nil}
        if let date = formatter.date(from: value) {
            return date
        } else {
            throw DateStrategyError.decode
        }
    }
    
    public static func encode(_ date: Date?) -> String? {
        guard let date else {return nil}
        return formatter.string(from: date)
    }
}
