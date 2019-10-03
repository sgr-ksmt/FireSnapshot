//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public extension Snapshot {
    @available(*, deprecated, renamed: "list(_:queryBuilder:source:completion:)")
    static func get(_ path: CollectionPath,
                    queryBuilder: QueryBuilder = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        list(path, queryBuilder: queryBuilder, source: source, completion: completion)
    }

    @available(*, deprecated, renamed: "list(_:queryBuilder:source:completion:)")
    static func get(_ reference: CollectionReference,
                    queryBuilder: QueryBuilder = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        list(reference, queryBuilder: queryBuilder, source: source, completion: completion)
    }

    @available(*, deprecated, renamed: "list(_:queryBuilder:source:completion:)")
    static func get<T>(_ collectionGroup: CollectionGroup<T>,
                       queryBuilder: QueryBuilder = { $0 },
                       source: FirestoreSource = .default,
                       completion: @escaping CollectionReadResultBlock<T>) where T: Codable {
        list(collectionGroup, queryBuilder: queryBuilder, source: source, completion: completion)
    }

    @available(*, deprecated, renamed: "listenList(_:queryBuilder:includeMetadataChanges:completion:)")
    static func listen(_ path: CollectionPath,
                     queryBuilder: QueryBuilder = { $0 },
                     includeMetadataChanges: Bool = false,
                     completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        listenList(
            path,
            queryBuilder: queryBuilder,
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }

    @available(*, deprecated, renamed: "listenList(_:queryBuilder:includeMetadataChanges:completion:)")
    static func listen(_ reference: CollectionReference,
                     queryBuilder: QueryBuilder = { $0 },
                     includeMetadataChanges: Bool = false,
                     completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        listenList(
            reference,
            queryBuilder: queryBuilder,
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }

    @available(*, deprecated, renamed: "listenList(_:queryBuilder:includeMetadataChanges:completion:)")
    static func listen<T>(_ collectionGroup: CollectionGroup<T>,
                       queryBuilder: QueryBuilder = { $0 },
                       includeMetadataChanges: Bool = false,
                       completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        listenList(
            collectionGroup,
            queryBuilder: queryBuilder,
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }
}
