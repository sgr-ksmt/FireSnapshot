//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

@propertyWrapper
public struct AtomicArray<E>: Codable where E: Codable, E: Equatable {
    private enum Operation {
        case union([E])
        case remove([E])
    }

    public var initialValue: [E]
    public var wrappedValue: [E]
    private var operation: Operation?
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }

    public init(wrappedValue: [E]) {
        initialValue = wrappedValue
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let array = try container.decode([E].self)
        initialValue = array
        wrappedValue = array
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let operation = operation {
            switch operation {
            case let .union(array):
                try container.encode(FieldValue.arrayUnion(array))
            case let .remove(array):
                try container.encode(FieldValue.arrayRemove(array))
            }
        } else {
            try container.encode(wrappedValue)
        }
    }

    public mutating func reset() {
        wrappedValue = initialValue
        operation = nil
    }

    public mutating func union(_ element: E) {
        union([element])
    }

    public mutating func union(_ array: [E]) {
        reset()
        wrappedValue.append(contentsOf: array)
        operation = .union(array)
    }

    public mutating func remove(_ element: E) {
        remove([element])
    }

    public mutating func remove(_ array: [E]) {
        reset()
        wrappedValue = wrappedValue.filter { !array.contains($0) }
        operation = .remove(array)
    }
}
