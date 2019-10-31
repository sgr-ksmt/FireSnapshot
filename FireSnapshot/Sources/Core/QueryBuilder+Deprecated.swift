//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public extension QueryBuilder {
    @discardableResult
    @available(*, unavailable, message: "Use '==' operator instead.")
    func `where`<V: Equatable>(_ keyPath: KeyPath<D, V>, isEqualTo value: V) -> Self {
        fatalError()
    }

    @discardableResult
    @available(*, unavailable, message: "Use '<' operator instead.")
    func `where`<V: Comparable>(_ keyPath: KeyPath<D, V>, isLessThan value: V) -> Self {
        fatalError()
    }

    @discardableResult
    @available(*, unavailable, message: "Use '<=' operator instead.")
    func `where`<V: Comparable>(_ keyPath: KeyPath<D, V>, isLessThanOrEqualTo value: V) -> Self {
        fatalError()
    }

    @discardableResult
    @available(*, unavailable, message: "Use '>' operator instead.")
    func `where`<V: Comparable>(_ keyPath: KeyPath<D, V>, isGreaterThan value: V) -> Self {
        fatalError()
    }

    @discardableResult
    @available(*, unavailable, message: "Use '>=' operator instead.")
    func `where`<V: Comparable>(_ keyPath: KeyPath<D, V>, isGreaterThanOrEqualTo value: V) -> Self {
        fatalError()
    }

    @discardableResult
    @available(*, unavailable, message: "Use '~=' operator instead.")
    func `where`<V: Equatable>(_ keyPath: KeyPath<D, [V]>, arrayContains value: V) -> Self {
        fatalError()
    }
}

public extension QueryBuilder where D: HasTimestamps {
    @discardableResult
    @available(*, unavailable, message: "Use '==' operator instead.")
    func `where`(_ key: SnapshotTimestampKey, isEqualTo value: Timestamp) -> Self {
        fatalError()
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isLessThan value: Timestamp) -> Self {
        fatalError()
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isLessThanOrEqualTo value: Timestamp) -> Self {
        fatalError()
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isGreaterThan value: Timestamp) -> Self {
        fatalError()
    }


    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isGreaterThanOrEqualTo value: Timestamp) -> Self {
        fatalError()
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isEqualTo value: Date) -> Self {
        fatalError()
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isLessThan value: Date) -> Self {
        fatalError()
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isLessThanOrEqualTo value: Date) -> Self {
        fatalError()
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isGreaterThan value: Date) -> Self {
        fatalError()
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isGreaterThanOrEqualTo value: Date) -> Self {
        fatalError()
    }
}
