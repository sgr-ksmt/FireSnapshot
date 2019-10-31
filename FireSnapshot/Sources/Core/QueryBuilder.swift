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

public extension QueryBuilder {
    @discardableResult
    func `where`<V: Equatable>(_ predicate: EqualPredicate<D, V>) -> Self {
        updateQuery(predicate.keyPath, builder: { $0.whereField($1, isEqualTo: predicate.value) })
        return self
    }

    @discardableResult
    func `where`<V: Comparable>(_ predicate: LessThanPredicate<D, V>) -> Self {
        updateQuery(predicate.keyPath, builder: { $0.whereField($1, isLessThan: predicate.value) })
        return self
    }

    @discardableResult
    func `where`<V: Comparable>(_ predicate: LessThanOrEqualPredicate<D, V>) -> Self {
        updateQuery(predicate.keyPath, builder: { $0.whereField($1, isLessThanOrEqualTo: predicate.value) })
        return self
    }

    @discardableResult
    func `where`<V: Comparable>(_ predicate: GreaterThanPredicate<D, V>) -> Self {
        updateQuery(predicate.keyPath, builder: { $0.whereField($1, isGreaterThan: predicate.value) })
        return self
    }

    @discardableResult
    func `where`<V: Comparable>(_ predicate: GreaterThanOrEqualPredicate<D, V>) -> Self {
        updateQuery(predicate.keyPath, builder: { $0.whereField($1, isGreaterThanOrEqualTo: predicate.value) })
        return self
    }

    @discardableResult
    func `where`<V: Equatable>(_ predicate: ArrayContainsPredicate<D, V>) -> Self where V: Equatable {
        updateQuery(predicate.keyPath, builder: { $0.whereField($1, arrayContains: predicate.value) })
        return self
    }

    @discardableResult
    func order(by keyPath: PartialKeyPath<D>, descending: Bool = false) -> Self {
        updateQuery(keyPath, builder: { $0.order(by: $1, descending: descending) })
        return self
    }

    @discardableResult
    func limit(to number: Int) -> Self {
        updateQuery("", builder: { query, _ in query.limit(to: number) })
        return self
    }

    @discardableResult
    func start(atDocument document: DocumentSnapshot) -> Self {
        updateQuery("", builder: { query, _ in query.start(atDocument: document) })
        return self
    }

    @discardableResult
    func start(afterDocument document: DocumentSnapshot) -> Self {
        updateQuery("", builder: { query, _ in query.start(afterDocument: document) })
        return self
    }

    @discardableResult
    func end(atDocument document: DocumentSnapshot) -> Self {
        updateQuery("", builder: { query, _ in query.end(atDocument: document) })
        return self
    }

    @discardableResult
    func end(beforeDocument document: DocumentSnapshot) -> Self {
        updateQuery("", builder: { query, _ in query.end(beforeDocument: document) })
        return self
    }

}

public extension QueryBuilder where D: HasTimestamps {
    @discardableResult
    func `where`(_ predicate: EqualTimestampPredicate<D>) -> Self {
        updateQuery(predicate.key.rawValue, builder: { $0.whereField($1, isEqualTo: predicate.value) })
        return self
    }

    @discardableResult
    func `where`(_ predicate: LessThanTimestampPredicate<D>) -> Self {
        updateQuery(predicate.key.rawValue, builder: { $0.whereField($1, isLessThan: predicate.value) })
        return self
    }

    @discardableResult
    func `where`(_ predicate: LessThanOrEqualTimestampPredicate<D>) -> Self {
        updateQuery(predicate.key.rawValue, builder: { $0.whereField($1, isLessThanOrEqualTo: predicate.value) })
        return self
    }

    @discardableResult
    func `where`(_ predicate: GreaterThanTimestampPredicate<D>) -> Self {
        updateQuery(predicate.key.rawValue, builder: { $0.whereField($1, isGreaterThan: predicate.value) })
        return self
    }

    @discardableResult
    func `where`(_ predicate: GreaterThanOrEqualTimestampPredicate<D>) -> Self {
        updateQuery(predicate.key.rawValue, builder: { $0.whereField($1, isGreaterThanOrEqualTo: predicate.value) })
        return self
    }

    @discardableResult
    func order(by key: SnapshotTimestampKey, descending: Bool = false) -> Self {
        updateQuery(key.rawValue, builder: { $0.order(by: $1, descending: descending) })
        return self
    }
}
