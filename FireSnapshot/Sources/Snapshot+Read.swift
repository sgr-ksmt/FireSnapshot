//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public extension Snapshot {
    typealias QueryBuilder = (Query) -> Query
    typealias DocumentReadResultBlock = (Result<Snapshot<D>, Error>) -> Void
    typealias CollectionReadResultBlock = (Result<[Snapshot<D>], Error>) -> Void

    static func get(_ path: DocumentPath,
                    source: FirestoreSource = .default,
                    completion: @escaping DocumentReadResultBlock) {
        get(path.documentReference, source: source, completion: completion)
    }

    static func get(_ reference: DocumentReference,
                    source: FirestoreSource = .default,
                    completion: @escaping DocumentReadResultBlock) {
        reference.getDocument(source: source, completion: documentReadCompletion(completion))
    }

    static func get(_ path: CollectionPath,
                    queryBuilder: QueryBuilder = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock) {
        get(path.collectionReference, queryBuilder: queryBuilder, source: source, completion: completion)
    }

    static func get(_ reference: CollectionReference,
                    queryBuilder: QueryBuilder = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock) {
        queryBuilder(reference).getDocuments(
            source: source,
            completion: collectionReadCompletion(completion)
        )
    }

    static func listen(_ path: DocumentPath,
                       includeMetadataChanges: Bool = false,
                       completion: @escaping DocumentReadResultBlock) {
        listen(path.documentReference, includeMetadataChanges: includeMetadataChanges, completion: completion)
    }

    static func listen(_ reference: DocumentReference,
                       includeMetadataChanges: Bool = false,
                       completion: @escaping DocumentReadResultBlock) {
        reference.addSnapshotListener(
            includeMetadataChanges: includeMetadataChanges,
            listener: documentReadCompletion(completion)
        )
    }

    static func listen(_ path: CollectionPath,
                     queryBuilder: QueryBuilder = { $0 },
                     includeMetadataChanges: Bool = false,
                     completion: @escaping CollectionReadResultBlock) -> ListenerRegistration {
        listen(
            path.collectionReference,
            queryBuilder: queryBuilder,
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }

    static func listen(_ reference: CollectionReference,
                     queryBuilder: QueryBuilder = { $0 },
                     includeMetadataChanges: Bool = false,
                     completion: @escaping CollectionReadResultBlock) -> ListenerRegistration {
        queryBuilder(reference).addSnapshotListener(
            includeMetadataChanges: includeMetadataChanges,
            listener: collectionReadCompletion(completion)
        )
    }

    private static func documentReadCompletion(_ completion: @escaping DocumentReadResultBlock) -> (DocumentSnapshot?, Error?) -> Void {
        return { snapshot, error in
            switch makeResult(snapshot, error) {
            case let .success(snapshot):
                do {
                    completion(.success(try .init(snapshot: snapshot)))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private static func collectionReadCompletion(_ completion: @escaping CollectionReadResultBlock) -> (QuerySnapshot?, Error?) -> Void {
        return { snapshot, error in
            if let snapshot = snapshot {
                do {
                    completion(.success(
                        try snapshot.documents
                            .compactMap { try Snapshot<D>(snapshot: $0) }
                        ))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
