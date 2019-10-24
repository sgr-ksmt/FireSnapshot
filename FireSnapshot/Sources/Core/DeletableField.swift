//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public struct DeletableField<T: Codable>: Codable {
    @propertyWrapper
    public struct Box<V>: Codable where V: Codable {
        private var initialValue: V?
        public fileprivate(set) var wrappedValue: V? {
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
            let value = !container.decodeNil() ? try container.decode(V.self) : nil
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

        mutating func delete() {
            deleted = true
            wrappedValue = nil
        }

        mutating func reset() {
            wrappedValue = initialValue
            deleted = false
        }
    }

    @Box public var value: T?

    public init(value: T? = nil) {
        self._value = Box(wrappedValue: value)
    }

    public init(from decoder: Decoder) throws {
        _value = try Box<T>(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try _value.encode(to: encoder)
    }

    public mutating func delete() {
        $value.delete()
    }

    public mutating func reset() {
        $value.reset()
    }
}
