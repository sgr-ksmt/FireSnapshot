//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

@propertyWrapper
public struct Reference<D>: Codable where D: SnapshotData {
    public var wrappedValue: DocumentReference?
    public init(wrappedValue: DocumentReference?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = nil
        } else {
            wrappedValue = try container.decode(DocumentReference.self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }

    public var projectedValue: Self {
        self
    }

    public func get(source: FirestoreSource = .default, completion: @escaping Snapshot<D>.DocumentReadResultBlock<D>) {
        guard let wrappedValue = wrappedValue else {
            completion(.failure(SnapshotError.notExists))
            return
        }
        Snapshot<D>.get(wrappedValue, source: source, completion: completion)
    }

    public func listen(includeMetadataChanges: Bool = false, completion: @escaping Snapshot<D>.DocumentReadResultBlock<D>) -> ListenerRegistration? {
        guard let wrappedValue = wrappedValue else {
            completion(.failure(SnapshotError.notExists))
            return nil
        }
        return Snapshot<D>.listen(wrappedValue, includeMetadataChanges: includeMetadataChanges, completion: completion)
    }
}
