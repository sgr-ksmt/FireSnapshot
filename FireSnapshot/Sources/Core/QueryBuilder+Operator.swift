//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation

public func == <D: SnapshotData, V: Equatable>(lhs: KeyPath<D, V>, rhs: V) -> EqualPredicate<D, V> {
    .init(KeyPath: lhs, value: rhs)
}

public func < <D: SnapshotData, V: Comparable>(lhs: KeyPath<D, V>, rhs: V) -> LessThanPredicate<D, V> {
    .init(KeyPath: lhs, value: rhs)
}

public func <= <D: SnapshotData, V: Comparable>(lhs: KeyPath<D, V>, rhs: V) -> LessThanOrEqualPredicate<D, V> {
    .init(KeyPath: lhs, value: rhs)
}

public func > <D: SnapshotData, V: Comparable>(lhs: KeyPath<D, V>, rhs: V) -> GreaterThanPredicate<D, V> {
    .init(KeyPath: lhs, value: rhs)
}

public func >= <D: SnapshotData, V: Comparable>(lhs: KeyPath<D, V>, rhs: V) -> GreaterThanOrEqualPredicate<D, V> {
    .init(KeyPath: lhs, value: rhs)
}

public func ~= <D: SnapshotData, V: Equatable>(lhs: KeyPath<D, [V]>, rhs: V) -> ArrayContainsPredicate<D, V> {
    .init(KeyPath: lhs, value: rhs)
}
