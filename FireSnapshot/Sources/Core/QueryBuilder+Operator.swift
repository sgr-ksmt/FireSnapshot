//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public func == <D: SnapshotData & FieldNameReferable, V: Equatable>(lhs: KeyPath<D, V>, rhs: V) -> EqualPredicate<D, V> {
    .init(keyPath: lhs, value: rhs)
}

public func < <D: SnapshotData & FieldNameReferable, V: Comparable>(lhs: KeyPath<D, V>, rhs: V) -> LessThanPredicate<D, V> {
    .init(keyPath: lhs, value: rhs)
}

public func <= <D: SnapshotData & FieldNameReferable, V: Comparable>(lhs: KeyPath<D, V>, rhs: V) -> LessThanOrEqualPredicate<D, V> {
    .init(keyPath: lhs, value: rhs)
}

public func > <D: SnapshotData & FieldNameReferable, V: Comparable>(lhs: KeyPath<D, V>, rhs: V) -> GreaterThanPredicate<D, V> {
    .init(keyPath: lhs, value: rhs)
}

public func >= <D: SnapshotData & FieldNameReferable, V: Comparable>(lhs: KeyPath<D, V>, rhs: V) -> GreaterThanOrEqualPredicate<D, V> {
    .init(keyPath: lhs, value: rhs)
}

public func ~= <D: SnapshotData & FieldNameReferable, V: Equatable>(lhs: KeyPath<D, [V]>, rhs: V) -> ArrayContainsPredicate<D, V> {
    .init(keyPath: lhs, value: rhs)
}

public func == <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Timestamp) -> EqualTimestampPredicate<D> {
    .init(key: lhs, value: rhs)
}

public func < <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Timestamp) -> LessThanTimestampPredicate<D> {
    .init(key: lhs, value: rhs)
}

public func <= <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Timestamp) -> LessThanOrEqualTimestampPredicate<D> {
    .init(key: lhs, value: rhs)
}

public func > <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Timestamp) -> GreaterThanTimestampPredicate<D> {
    .init(key: lhs, value: rhs)
}

public func >= <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Timestamp) -> GreaterThanOrEqualTimestampPredicate<D> {
    .init(key: lhs, value: rhs)
}

public func == <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Date) -> EqualTimestampPredicate<D> {
    .init(key: lhs, value: .init(date: rhs))
}

public func < <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Date) -> LessThanTimestampPredicate<D> {
    .init(key: lhs, value: .init(date: rhs))
}

public func <= <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Date) -> LessThanOrEqualTimestampPredicate<D> {
    .init(key: lhs, value: .init(date: rhs))
}

public func > <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Date) -> GreaterThanTimestampPredicate<D> {
    .init(key: lhs, value: .init(date: rhs))
}

public func >= <D: SnapshotData & HasTimestamps>(lhs: SnapshotTimestampKey, rhs: Date) -> GreaterThanOrEqualTimestampPredicate<D> {
    .init(key: lhs, value: .init(date: rhs))
}
