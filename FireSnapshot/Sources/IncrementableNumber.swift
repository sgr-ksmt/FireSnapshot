//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public protocol IncrementableNumber: Codable {
    associatedtype Number: AdditiveArithmetic, Codable
    init(wrappedValue: Number)
    var initialValue: Number { get }
    var wrappedValue: Number { get set }
    var incrementValue: Number? { get set }
    func makeFieldValue () -> FieldValue?
}

public extension IncrementableNumber {
    mutating func reset() {
        wrappedValue = initialValue
        incrementValue = nil
    }

    mutating func increment(_ value: Number) {
        incrementValue = value
        wrappedValue += value
    }

    static func decode(from decoder: Decoder) throws -> Number {
        try (try decoder.singleValueContainer()).decode(Number.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let increment = makeFieldValue() {
            try container.encode(increment)
        } else {
            try container.encode(wrappedValue)
        }
    }
}
