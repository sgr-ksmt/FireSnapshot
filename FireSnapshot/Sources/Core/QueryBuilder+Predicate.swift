//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public protocol WhereQueryPredicate {
    associatedtype Data: SnapshotData & FieldNameReferable
    associatedtype Value

    var keyPath: KeyPath<Data, Value> { get }
    var value: Value { get }
}

public protocol ArrayContainsWhereQueryPredicate {
    associatedtype Data: SnapshotData & FieldNameReferable
    associatedtype Value: Equatable

    var keyPath: KeyPath<Data, [Value]> { get }
    var value: Value { get }
}

public struct EqualPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var keyPath: KeyPath<D, V>
    public var value: V
}

public struct LessThanPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var keyPath: KeyPath<D, V>
    public var value: V
}

public struct LessThanOrEqualPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var keyPath: KeyPath<D, V>
    public var value: V
}

public struct GreaterThanPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var keyPath: KeyPath<D, V>
    public var value: V
}

public struct GreaterThanOrEqualPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: WhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var keyPath: KeyPath<D, V>
    public var value: V
}

public struct ArrayContainsPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: ArrayContainsWhereQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var keyPath: KeyPath<D, [V]>
    public var value: V
}

public protocol TimeStampWhereQueryPredicate {
    associatedtype Data: SnapshotData & HasTimestamps

    var key: SnapshotTimestampKey { get }
    var value: Timestamp { get }
}

public struct EqualTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

public struct LessThanTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

public struct LessThanOrEqualTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

public struct GreaterThanTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

public struct GreaterThanOrEqualTimestampPredicate<D: SnapshotData & HasTimestamps>: TimeStampWhereQueryPredicate {
    public typealias Data = D
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

