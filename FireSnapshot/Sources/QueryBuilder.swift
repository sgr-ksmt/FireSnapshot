//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public final class QueryBuilder<D> where D: FieldNameReferable {
    private(set) var query: Query
    public init(_ query: Query) {
        self.query = query
    }

    public func generate() -> Query {
        query
    }

    public func `where`<V>(_ keyPath: KeyPath<D, V>, isEqualTo value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isEqualTo: value) })
        return self
    }

    public func `where`<V>(_ keyPath: KeyPath<D, V>, isLessThan value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isLessThan: value) })
        return self
    }

    public func `where`<V>(_ keyPath: KeyPath<D, V>, isGreaterThan value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isGreaterThan: value) })
        return self
    }

    public func `where`<V>(_ keyPath: KeyPath<D, V>, isLessThanOrEqualTo value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isLessThanOrEqualTo: value) })
        return self
    }

    public func `where`<V>(_ keyPath: KeyPath<D, V>, isGreaterThanOrEqualTo value: V) -> Self {
        updateQuery(keyPath, builder: { $0.whereField($1, isGreaterThanOrEqualTo: value) })
        return self
    }

    public func `where`<V>(_ keyPath: KeyPath<D, Array<V>>, arrayContains value: V) -> Self where V: Equatable {
        updateQuery(keyPath, builder: { $0.whereField($1, arrayContains: value) })
        return self
    }

    public func order(_ keyPath: PartialKeyPath<D>, descending: Bool = false) -> Self {
        updateQuery(keyPath, builder: { $0.order(by: $1, descending: descending) })
        return self
    }

    public func limit(to number: Int) -> Self {
        query = query.limit(to: number)
        return self
    }

    public func start(atDocument document: DocumentSnapshot) -> Self {
        query = query.start(atDocument: document)
        return self
    }

    public func start(afterDocument document: DocumentSnapshot) -> Self {
        query = query.start(afterDocument: document)
        return self
    }

    public func end(atDocument document: DocumentSnapshot) -> Self {
        query = query.end(atDocument: document)
        return self
    }

    public func end(beforeDocument document: DocumentSnapshot) -> Self {
        query = query.end(beforeDocument: document)
        return self
    }

    private func updateQuery(_ keyPath: PartialKeyPath<D>, builder: (Query, String) -> Query) {
        guard let fieldName = D.fieldName(from: keyPath) else {
            print("[Warn] field name for \(keyPath) is not found.")
            return
        }
        query = builder(query, fieldName)
    }
}

extension QueryBuilder where D: HasTimestamps {
    public func `where`(_ key: SnapshotTimestampKey, isEqualTo value: Timestamp) -> Self {
        query = query.whereField(key.rawValue, isEqualTo: value)
        return self
    }

    public func `where`(_ key: SnapshotTimestampKey, isLessThan value: Timestamp) -> Self {
        query = query.whereField(key.rawValue, isLessThan: value)
        return self
    }

    public func `where`(_ key: SnapshotTimestampKey, isGreaterThan value: Timestamp) -> Self {
        query = query.whereField(key.rawValue, isGreaterThan: value)
        return self
    }

    public func `where`(_ key: SnapshotTimestampKey, isLessThanOrEqualTo value: Timestamp) -> Self {
        query = query.whereField(key.rawValue, isLessThanOrEqualTo: value)
        return self
    }

    public func `where`(_ key: SnapshotTimestampKey, isGreaterThanOrEqualTo value: Timestamp) -> Self {
        query = query.whereField(key.rawValue, isGreaterThanOrEqualTo: value)
        return self
    }

    public func `where`(_ key: SnapshotTimestampKey, isEqualTo value: Date) -> Self {
        `where`(key, isEqualTo: Timestamp(date: value))
    }

    public func `where`(_ key: SnapshotTimestampKey, isLessThan value: Date) -> Self {
        `where`(key, isLessThan: Timestamp(date: value))
    }

    public func `where`(_ key: SnapshotTimestampKey, isGreaterThan value: Date) -> Self {
        `where`(key, isGreaterThan: Timestamp(date: value))
    }

    public func `where`(_ key: SnapshotTimestampKey, isLessThanOrEqualTo value: Date) -> Self {
        `where`(key, isLessThanOrEqualTo: Timestamp(date: value))
    }

    public func `where`(_ key: SnapshotTimestampKey, isGreaterThanOrEqualTo value: Date) -> Self {
        `where`(key, isGreaterThanOrEqualTo: Timestamp(date: value))
    }

    public func order(_ key: SnapshotTimestampKey, descending: Bool = false) -> Self {
        query = query.order(by: key.rawValue, descending: descending)
        return self
    }
}
