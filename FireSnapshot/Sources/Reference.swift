//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

@propertyWrapper
public struct Reference<D>: Codable where D: SnapshotData {
    public private(set) var wrappedValue: DocumentReference
    public init(wrappedValue: DocumentReference) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(DocumentReference.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }

    public var projectedValue: Self {
        self
    }

    func get(source: FirestoreSource = .default, completion: @escaping Snapshot<D>.DocumentReadResultBlock<D>) {
        Snapshot<D>.get(wrappedValue, source: source, completion: completion)
    }

    func listen(includeMetadataChanges: Bool = false, completion: @escaping Snapshot<D>.DocumentReadResultBlock<D>) {
        Snapshot<D>.listen(wrappedValue, includeMetadataChanges: includeMetadataChanges, completion: completion)
    }
}
