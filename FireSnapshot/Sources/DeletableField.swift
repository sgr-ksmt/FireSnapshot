//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

@propertyWrapper
public struct DeletableField<V>: Codable where V: Codable {
    public var initialValue: V?
    public var wrappedValue: V? {
        didSet {
            if wrappedValue != nil {
                deleted = false
            }
        }
    }
    private var deleted: Bool = false
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }
    public init(wrappedValue: V?) {
        initialValue = wrappedValue
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(V.self)
        initialValue = value
        wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if deleted {
            try container.encode(FieldValue.delete())
        } else {
            try container.encode(wrappedValue)
        }
    }

    public mutating func delete() {
        deleted = true
    }

    public mutating func reset() {
        wrappedValue = initialValue
        deleted = false
    }
}
