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

public struct EqualPredicate<D, V>: WhereQueryPredicate where D: SnapshotData & FieldNameReferable {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct LessThanPredicate<D, V>: WhereQueryPredicate where D: SnapshotData & FieldNameReferable {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct LessThanOrEqualPredicate<D, V>: WhereQueryPredicate where D: SnapshotData & FieldNameReferable {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct GreaterThanPredicate<D, V>: WhereQueryPredicate where D: SnapshotData & FieldNameReferable {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct GreaterThanOrEqualPredicate<D, V>: WhereQueryPredicate where D: SnapshotData & FieldNameReferable {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, V>
    public var value: V
}

public struct ArrayContainsPredicate<D, V>: WhereArrayContainsQueryPredicate where D: SnapshotData & FieldNameReferable, V: Equatable {
    public typealias Data = D
    public typealias Value = V
    public var KeyPath: KeyPath<D, [V]>
    public var value: V
}
