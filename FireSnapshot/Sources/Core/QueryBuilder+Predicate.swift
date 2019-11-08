//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public protocol QueryPredicate {
    associatedtype Data: SnapshotData & FieldNameReferable
    associatedtype Value
    associatedtype CompareValue
}

public protocol KeyPathQueryPredicate: QueryPredicate {
    var keyPath: KeyPath<Data, Value> { get }
    var value: CompareValue { get }
}

public protocol EqualQueryPredicate: KeyPathQueryPredicate where Value: Equatable, CompareValue == Value {
}

public protocol CompareQueryPredicate: EqualQueryPredicate where Value: Comparable {
}

public struct EqualPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: EqualQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public typealias CompareValue = Value
    public var keyPath: KeyPath<Data, Value>
    public var value: CompareValue
}

public struct LessThanPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: CompareQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public typealias CompareValue = Value
    public var keyPath: KeyPath<Data, Value>
    public var value: CompareValue
}

public struct LessThanOrEqualPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: CompareQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public typealias CompareValue = Value
    public var keyPath: KeyPath<Data, Value>
    public var value: CompareValue
}

public struct GreaterThanPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: CompareQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public typealias CompareValue = Value
    public var keyPath: KeyPath<Data, Value>
    public var value: CompareValue
}

public struct GreaterThanOrEqualPredicate<D: SnapshotData & FieldNameReferable, V: Comparable>: CompareQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public typealias CompareValue = Value
    public var keyPath: KeyPath<Data, Value>
    public var value: CompareValue
}

public struct ArrayContainsPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: QueryPredicate {
    public typealias Data = D
    public typealias Value = [V]
    public typealias CompareValue = V
    public var keyPath: KeyPath<Data, Value>
    public var value: CompareValue
}

public struct ArrayContainsAnyPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: QueryPredicate {
    public typealias Data = D
    public typealias Value = [V]
    public typealias CompareValue = Value
    public var keyPath: KeyPath<Data, Value>
    public var value: CompareValue
}

public struct InPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: QueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public typealias CompareValue = [V]
    public var keyPath: KeyPath<Data, Value>
    public var value: CompareValue
}

public protocol TimestampQueryPredicate: QueryPredicate where CompareValue == Timestamp {
    var key: SnapshotTimestampKey { get }
    var value: CompareValue { get }
}

public struct EqualTimestampPredicate<D: SnapshotData & HasTimestamps & FieldNameReferable>: TimestampQueryPredicate {
    public typealias Data = D
    public typealias Value = Timestamp
    public typealias CompareValue = Value
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

public struct LessThanTimestampPredicate<D: SnapshotData & HasTimestamps & FieldNameReferable>: TimestampQueryPredicate {
    public typealias Data = D
    public typealias Value = Timestamp
    public typealias CompareValue = Value
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

public struct LessThanOrEqualTimestampPredicate<D: SnapshotData & HasTimestamps & FieldNameReferable>: TimestampQueryPredicate {
    public typealias Data = D
    public typealias Value = Timestamp
    public typealias CompareValue = Value
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

public struct GreaterThanTimestampPredicate<D: SnapshotData & HasTimestamps & FieldNameReferable>: TimestampQueryPredicate {
    public typealias Data = D
    public typealias Value = Timestamp
    public typealias CompareValue = Value
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}

public struct GreaterThanOrEqualTimestampPredicate<D: SnapshotData & HasTimestamps & FieldNameReferable>: TimestampQueryPredicate {
    public typealias Data = D
    public typealias Value = Timestamp
    public typealias CompareValue = Value
    public var key: SnapshotTimestampKey
    public var value: Timestamp
}
