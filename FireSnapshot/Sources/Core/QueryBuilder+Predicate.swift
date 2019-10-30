//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation

public protocol WhereQueryPredicate {
    associatedtype Data: SnapshotData & FieldNameReferable
    associatedtype Value

    var KeyPath: KeyPath<Data, Value> { get }
    var value: Value { get }
}

public protocol WhereArrayContainsQueryPredicate {
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

public struct ArrayContainsPredicate<D: SnapshotData & FieldNameReferable, V: Equatable>: WhereArrayContainsQueryPredicate {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, [V]>
    public var value: V
}
