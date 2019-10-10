//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public extension Snapshot {
    typealias QueryBuildBlock = (Query) -> Query
    typealias DocumentReadResultBlock<T: SnapshotData> = (Result<Snapshot<T>, Error>) -> Void
    typealias CollectionReadResultBlock<T: SnapshotData> = (Result<[Snapshot<T>], Error>) -> Void

    static func get(_ path: DocumentPath<Data>,
                    source: FirestoreSource = .default,
                    completion: @escaping DocumentReadResultBlock<Data>) {
        get(path.documentReference, source: source, completion: completion)
    }

    static func get(_ reference: DocumentReference,
                    source: FirestoreSource = .default,
                    completion: @escaping DocumentReadResultBlock<Data>) {
        reference.getDocument(source: source, completion: documentReadCompletion(completion))
    }

    static func get(_ path: CollectionPath<Data>,
                    queryBuildBlock: QueryBuildBlock = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        get(path.collectionReference, queryBuildBlock: queryBuildBlock, source: source, completion: completion)
    }

    static func get(_ reference: CollectionReference,
                    queryBuildBlock: QueryBuildBlock = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        queryBuildBlock(reference).getDocuments(
            source: source,
            completion: collectionReadCompletion(completion)
        )
    }

    static func get(collectionGroup: CollectionGroup<Data>,
                    queryBuildBlock: QueryBuildBlock = { $0 },
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        queryBuildBlock(collectionGroup.query).getDocuments(
            source: source,
            completion: collectionReadCompletion(completion)
        )
    }

    static func listen(_ path: DocumentPath<Data>,
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

    static func listen(_ path: CollectionPath<Data>,
                       queryBuildBlock: QueryBuildBlock = { $0 },
                       includeMetadataChanges: Bool = false,
                       completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        listen(
            path.collectionReference,
            queryBuildBlock: queryBuildBlock,
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }

    static func listen(_ reference: CollectionReference,
                       queryBuildBlock: QueryBuildBlock = { $0 },
                       includeMetadataChanges: Bool = false,
                       completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        queryBuildBlock(reference).addSnapshotListener(
            includeMetadataChanges: includeMetadataChanges,
            listener: collectionReadCompletion(completion)
        )
    }

    static func listen(collectionGroup: CollectionGroup<Data>,
                       queryBuildBlock: QueryBuildBlock = { $0 },
                       includeMetadataChanges: Bool = false,
                       completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        queryBuildBlock(collectionGroup.query).addSnapshotListener(
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

public extension Snapshot where Data: FieldNameReferable {
    typealias QueryBuilderBlock<T: SnapshotData & FieldNameReferable> = (QueryBuilder<T>) -> QueryBuilder<T>

    static func get(_ path: CollectionPath<Data>,
                    queryBuilderBlock: QueryBuilderBlock<Data>,
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        get(
            path.collectionReference,
            queryBuilderBlock: queryBuilderBlock,
            source: source,
            completion: completion
        )
    }

    static func get(_ reference: CollectionReference,
                    queryBuilderBlock: QueryBuilderBlock<Data>,
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        get(
            reference,
            queryBuildBlock: { queryBuilderBlock(QueryBuilder<Data>($0)).generate() },
            source: source,
            completion: completion
        )
    }

    static func get(collectionGroup: CollectionGroup<Data>,
                    queryBuilderBlock: QueryBuilderBlock<Data>,
                    source: FirestoreSource = .default,
                    completion: @escaping CollectionReadResultBlock<Data>) {
        get(
            collectionGroup: collectionGroup,
            queryBuildBlock: { queryBuilderBlock(QueryBuilder<Data>($0)).generate() },
            source: source,
            completion: completion
        )
    }

    static func listen(_ path: CollectionPath<Data>,
                       queryBuilderBlock: QueryBuilderBlock<Data>,
                       includeMetadataChanges: Bool = false,
                       completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        listen(
            path.collectionReference,
            queryBuilderBlock: queryBuilderBlock,
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }

    static func listen(_ reference: CollectionReference,
                       queryBuilderBlock: QueryBuilderBlock<Data>,
                       includeMetadataChanges: Bool = false,
                       completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        listen(
            reference,
            queryBuildBlock: { queryBuilderBlock(QueryBuilder<Data>($0)).generate() },
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }

    static func listen(collectionGroup: CollectionGroup<Data>,
                       queryBuilderBlock: QueryBuilderBlock<Data>,
                       includeMetadataChanges: Bool = false,
                       completion: @escaping CollectionReadResultBlock<Data>) -> ListenerRegistration {
        listen(
            collectionGroup: collectionGroup,
            queryBuildBlock: { queryBuilderBlock(QueryBuilder<Data>($0)).generate() },
            includeMetadataChanges: includeMetadataChanges,
            completion: completion
        )
    }
}
