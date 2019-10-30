//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public final class QueryBuilder<D: SnapshotData & FieldNameReferable> {
    private(set) var call: Int = 0
    private(set) var stack: Int = 0
    private(set) var query: Query
    public init(_ query: Query) {
        self.query = query
    }

    @discardableResult
    public func generate() -> Query {
        query
    }

    @discardableResult
    public func `where`<V: Equatable>(_ keyPath: KeyPath<D, V>, isEqualTo value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isEqualTo: value) })
        return self
    }

    @discardableResult
    public func `where`<V: Comparable>(_ keyPath: KeyPath<D, V>, isLessThan value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isLessThan: value) })
        return self
    }

    @discardableResult
    public func `where`<V: Comparable>(_ keyPath: KeyPath<D, V>, isGreaterThan value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isGreaterThan: value) })
        return self
    }

    @discardableResult
    public func `where`<V: Comparable>(_ keyPath: KeyPath<D, V>, isLessThanOrEqualTo value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isLessThanOrEqualTo: value) })
        return self
    }

    @discardableResult
    public func `where`<V: Comparable>(_ keyPath: KeyPath<D, V>, isGreaterThanOrEqualTo value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isGreaterThanOrEqualTo: value) })
        return self
    }

    @discardableResult
    public func `where`<V: Equatable>(_ keyPath: KeyPath<D, [V]>, arrayContains value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, arrayContains: value) })
        return self
    }

    @discardableResult
    public func order(by keyPath: PartialKeyPath<D>, descending: Bool = false) -> Self {
        updateQuery(keyPath, builder: { $0.order(by: $1, descending: descending) })
        return self
    }

    @discardableResult
    public func limit(to number: Int) -> Self {
        updateQuery("", builder: { query, _ in query.limit(to: number) })
        return self
    }

    @discardableResult
    public func start(atDocument document: DocumentSnapshot) -> Self {
        updateQuery("", builder: { query, _ in query.start(atDocument: document) })
        return self
    }

    @discardableResult
    public func start(afterDocument document: DocumentSnapshot) -> Self {
        updateQuery("", builder: { query, _ in query.start(afterDocument: document) })
        return self
    }

    @discardableResult
    public func end(atDocument document: DocumentSnapshot) -> Self {
        updateQuery("", builder: { query, _ in query.end(atDocument: document) })
        return self
    }

    @discardableResult
    public func end(beforeDocument document: DocumentSnapshot) -> Self {
        updateQuery("", builder: { query, _ in query.end(beforeDocument: document) })
        return self
    }

    private func updateQuery(_ keyPath: PartialKeyPath<D>, builder: (Query, String) -> Query) {
        call += 1
        guard let fieldName = D.fieldName(from: keyPath) else {
            print("[Warn] field name for \(keyPath) is not found.")
            return
        }
        _updateQuery(fieldName, builder: builder)
    }

    private func updateQuery(_ fieldName: String, builder: (Query, String) -> Query) {
        call += 1
        _updateQuery(fieldName, builder: builder)
    }

    private func _updateQuery(_ fieldName: String, builder: (Query, String) -> Query) {
        query = builder(query, fieldName)
        stack += 1
    }
}

public extension QueryBuilder where D: HasTimestamps {
    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isEqualTo value: Timestamp) -> Self {
        updateQuery(key.rawValue, builder: { $0.whereField($1, isEqualTo: value) })
        return self
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isLessThan value: Timestamp) -> Self {
        updateQuery(key.rawValue, builder: { $0.whereField($1, isLessThan: value) })
        return self
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isGreaterThan value: Timestamp) -> Self {
        updateQuery(key.rawValue, builder: { $0.whereField($1, isGreaterThan: value) })
        return self
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isLessThanOrEqualTo value: Timestamp) -> Self {
        updateQuery(key.rawValue, builder: { $0.whereField($1, isLessThanOrEqualTo: value) })
        return self
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isGreaterThanOrEqualTo value: Timestamp) -> Self {
        updateQuery(key.rawValue, builder: { $0.whereField($1, isGreaterThanOrEqualTo: value) })
        return self
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isEqualTo value: Date) -> Self {
        `where`(key, isEqualTo: Timestamp(date: value))
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isLessThan value: Date) -> Self {
        `where`(key, isLessThan: Timestamp(date: value))
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isGreaterThan value: Date) -> Self {
        `where`(key, isGreaterThan: Timestamp(date: value))
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isLessThanOrEqualTo value: Date) -> Self {
        `where`(key, isLessThanOrEqualTo: Timestamp(date: value))
    }

    @discardableResult
    func `where`(_ key: SnapshotTimestampKey, isGreaterThanOrEqualTo value: Date) -> Self {
        `where`(key, isGreaterThanOrEqualTo: Timestamp(date: value))
    }

    @discardableResult
    func order(by key: SnapshotTimestampKey, descending: Bool = false) -> Self {
        updateQuery(key.rawValue, builder: { $0.order(by: $1, descending: descending) })
        return self
    }
}

public extension QueryBuilder {
    @discardableResult
    func `where`<V: Equatable>(_ predicate: EqualPredicate<D, V>) -> Self {
        return `where`(predicate.KeyPath, isEqualTo: predicate.value)
    }

    @discardableResult
    func `where`<V: Comparable>(_ predicate: LessThanPredicate<D, V>) -> Self {
        return `where`(predicate.KeyPath, isLessThan: predicate.value)
    }

    @discardableResult
    func `where`<V: Comparable>(_ predicate: LessThanOrEqualPredicate<D, V>) -> Self {
        return `where`(predicate.KeyPath, isLessThanOrEqualTo: predicate.value)
    }

    @discardableResult
    func `where`<V: Comparable>(_ predicate: GreaterThanPredicate<D, V>) -> Self {
        return `where`(predicate.KeyPath, isGreaterThan: predicate.value)
    }

    @discardableResult
    func `where`<V: Comparable>(_ predicate: GreaterThanOrEqualPredicate<D, V>) -> Self {
        return `where`(predicate.KeyPath, isGreaterThanOrEqualTo: predicate.value)
    }

    @discardableResult
    func `where`<V: Equatable>(_ predicate: ArrayContainsPredicate<D, V>) -> Self where V: Equatable {
        return `where`(predicate.KeyPath, arrayContains: predicate.value)
    }
}

public extension QueryBuilder where D: HasTimestamps {
    @discardableResult
    func `where`(_ predicate: EqualTimestampPredicate<D>) -> Self {
        return `where`(predicate.key, isEqualTo: predicate.value)
    }

    @discardableResult
    func `where`(_ predicate: LessThanTimestampPredicate<D>) -> Self {
        return `where`(predicate.key, isLessThan: predicate.value)
    }

    @discardableResult
    func `where`(_ predicate: LessThanOrEqualTimestampPredicate<D>) -> Self {
        return `where`(predicate.key, isLessThanOrEqualTo: predicate.value)
    }

    @discardableResult
    func `where`(_ predicate: GreaterThanTimestampPredicate<D>) -> Self {
        return `where`(predicate.key, isGreaterThan: predicate.value)
    }

    @discardableResult
    func `where`(_ predicate: GreaterThanOrEqualTimestampPredicate<D>) -> Self {
        return `where`(predicate.key, isGreaterThanOrEqualTo: predicate.value)
    }
}
