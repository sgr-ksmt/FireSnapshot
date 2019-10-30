//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public protocol WhereQueryPredicate {
    associatedtype Data: SnapshotData & FieldNameReferable
    associatedtype Value

    var KeyPath: KeyPath<Data, Value> { get }
    var value: Value { get }
}

public protocol ArrayContainsWhereQueryPredicate {
    associatedtype Data: SnapshotData & FieldNameReferable
    associatedtype Value: Equatable

    var KeyPath: KeyPath<Data, [Value]> { get }
    var value: Value { get }
}

public struct EqualPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct LessThanPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct LessThanOrEqualPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct GreaterThanPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct GreaterThanOrEqualPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct ArrayContainsPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: ArrayContainsWhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, [V]>
    public var value: V
}

public protocol TimeStampWhereQueryPredicate {
    associatedtype Data: SnapshotData & HasTimestamps

    var key: SnapshotTimestampKey { get }
    var value: Timestamp { get }
    init(key: SnapshotTimestampKey, value: Timestamp)
    init(key: SnapshotTimestampKey, value: Date)
}

public struct EqualTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp

    public init(key: SnapshotTimestampKey, value: Timestamp) {
        self.key = key
        self.value = value
    }

    public init(key: SnapshotTimestampKey, value: Date) {
        self.key = key
        self.value = .init(date: value)
    }
}

public struct LessThanTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp

    public init(key: SnapshotTimestampKey, value: Timestamp) {
        self.key = key
        self.value = value
    }

    public init(key: SnapshotTimestampKey, value: Date) {
        self.key = key
        self.value = .init(date: value)
    }
}

public struct LessThanOrEqualTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp

    public init(key: SnapshotTimestampKey, value: Timestamp) {
        self.key = key
        self.value = value
    }

    public init(key: SnapshotTimestampKey, value: Date) {
        self.key = key
        self.value = .init(date: value)
    }
}

public struct GreaterThanTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp

    public init(key: SnapshotTimestampKey, value: Timestamp) {
        self.key = key
        self.value = value
    }

    public init(key: SnapshotTimestampKey, value: Date) {
        self.key = key
        self.value = .init(date: value)
    }
}

public struct GreaterThanOrEqualTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp

    public init(key: SnapshotTimestampKey, value: Timestamp) {
        self.key = key
        self.value = value
    }

    public init(key: SnapshotTimestampKey, value: Date) {
        self.key = key
        self.value = .init(date: value)
    }
}

