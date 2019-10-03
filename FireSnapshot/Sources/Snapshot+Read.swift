//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public extension Snapshot {
    typealias QueryBuilder = (Query) -> Query
    typealias DocumentReadResultBlock<T: Codable> = (Result<Snapshot<T>, Error>) -> Void
    typealias CollectionReadResultBlock<T: Codable> = (Result<[Snapshot<T>], Error>) -> Void

    static func get(_ path: DocumentPath,
                    source: FirestoreSource = .default,
                    completion: @escaping DocumentReadResultBlock<Data>) {
        get(path.documentReference, source: source, completion: completion)
    }

    static func get(_ reference: DocumentReference,
                    source: FirestoreSource = .default,
                    completion: @escaping DocumentReadResultBlock<Data>) {
        reference.getDocument(source: source, completion: documentReadCompletion(completion))
    }

    static func list(_ path: CollectionPath,
                    queryBuilder: QueryBuilder = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        list(path.collectionReference, queryBuilder: queryBuilder, source: source, completion: completion)
    }

    static func list(_ reference: CollectionReference,
                    queryBuilder: QueryBuilder = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        queryBuilder(reference).getDocuments(
            source: source,
            completion: collectionReadCompletion(completion)
        )
    }

    static func list<T>(_ collectionGroup: CollectionGroup<T>,
                       queryBuilder: QueryBuilder = { $0 },
                       source: FirestoreSource = .default,
                       completion: @escaping CollectionReadResultBlock<T>) where T: Codable {
        queryBuilder(collectionGroup.query).getDocuments(
            source: source,
            completion: collectionReadCompletion(completion)
        )
    }

    static func listen(_ path: DocumentPath,
                       includeMetadataChanges: Bool = false,
                       completion: @escaping DocumentReadResultBlock<Data>) {
        listen(path.documentReference, includeMetadataChanges: includeMetadataChanges, completion: completion)
    }

    static func listen(_ reference: DocumentReference,
                       includeMetadataChanges: Bool = false,
                       completion: @escaping DocumentReadResultBlock<Data>) {
        reference.addSnapshotListener(
            includeMetadataChanges: includeMetadataChanges,
            listener: documentReadCompletion(completion)
        )
    }

    static func listenList(_ path: CollectionPath,
                     queryBuilder: QueryBuilder = { $0 },
                     includeMetadataChanges: Bool = false,
                     completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        listenList(
            path.collectionReference,
            queryBuilder: queryBuilder,
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }

    static func listenList(_ reference: CollectionReference,
                     queryBuilder: QueryBuilder = { $0 },
                     includeMetadataChanges: Bool = false,
                     completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        queryBuilder(reference).addSnapshotListener(
            includeMetadataChanges: includeMetadataChanges,
            listener: collectionReadCompletion(completion)
        )
    }

    static func listenList<T>(_ collectionGroup: CollectionGroup<T>,
                       queryBuilder: QueryBuilder = { $0 },
                       includeMetadataChanges: Bool = false,
                       completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        queryBuilder(collectionGroup.query).addSnapshotListener(
            includeMetadataChanges: includeMetadataChanges,
            listener: collectionReadCompletion(completion)
        )
    }

    private static func documentReadCompletion<T>(_ completion: @escaping DocumentReadResultBlock<T>) -> (DocumentSnapshot?, Error?) -> Void {
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

    private static func collectionReadCompletion<T>(_ completion: @escaping CollectionReadResultBlock<T>) -> (QuerySnapshot?, Error?) -> Void {
        return { snapshot, error in
            if let snapshot = snapshot {
                do {
                    completion(.success(try snapshot.documents.compactMap { try .init(snapshot: $0) }))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
