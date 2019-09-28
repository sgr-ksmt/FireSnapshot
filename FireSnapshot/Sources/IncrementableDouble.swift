//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

@propertyWrapper
public struct IncrementableDouble: IncrementableNumber {
    public typealias Number = Double

    public private (set) var initialValue: Number
    public var wrappedValue: Number
    public var incrementValue: Number?
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }

    public init(wrappedValue: Number) {
        initialValue = wrappedValue
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let value = try Self.decode(from: decoder)
        initialValue = value
        wrappedValue = value
    }

    public func makeFieldValue() -> FieldValue? {
        incrementValue.map { FieldValue.increment($0) }
    }
}
