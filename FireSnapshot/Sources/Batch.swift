//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public final class Batch {
    enum SnapshotBag {
        typealias FieldExtractBlock = () throws -> [String: Any]

        case create(reference: DocumentReference, extractor: FieldExtractBlock)
        case update(reference: DocumentReference, extractor: FieldExtractBlock)
        case delete(reference: DocumentReference)
    }

    private var bags: [SnapshotBag] = []
    public init() {
    }

    @discardableResult
    public func create<D>(_ snapshot: Snapshot<D>) -> Self where D: SnapshotData {
        bags.append(.create(reference: snapshot.reference, extractor: {
            try snapshot.extractWriteFieldsForCreate()
        }))
        return self
    }

    @discardableResult
    public func update<D>(_ snapshot: Snapshot<D>) -> Self where D: SnapshotData {
        bags.append(.update(reference: snapshot.reference, extractor: { try snapshot.extractWriteFieldsForUpdate() }))
        return self
    }

    @discardableResult
    public func delete<D>(_ snapshot: Snapshot<D>) -> Self where D: SnapshotData {
        bags.append(.delete(reference: snapshot.reference))
        return self
    }

    public func commit(completion: @escaping (Error?) -> Void) {
        do {
            (try asWriteBatch()).commit(completion: completion)
        } catch {
            completion(error)
        }
    }

    public func asWriteBatch() throws -> WriteBatch {
        let batch = Firestore.firestore().batch()
        try bags.forEach { bag in
            switch bag {
            case let .create(reference, extractor):
                batch.setData(try extractor(), forDocument: reference)
            case let .update(reference, extractor):
                batch.updateData(try extractor(), forDocument: reference)
            case let .delete(reference):
                batch.deleteDocument(reference)
            }
        }
        return batch
    }
}
