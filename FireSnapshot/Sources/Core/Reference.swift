//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public protocol ReferenceWrappable {
    static func wrap(_ documentReference: DocumentReference) throws -> Self
    static func unwrap(_ value: Self) throws -> DocumentReference
}

extension String: ReferenceWrappable {
    public static func wrap(_ documentReference: DocumentReference) throws -> Self {
        documentReference.path
    }

    public static func unwrap(_ value: Self) throws -> DocumentReference {
        AnyDocumentPath(value).documentReference
    }
}

extension DocumentReference: ReferenceWrappable {
    public static func wrap(_ documentReference: DocumentReference) throws -> Self {
        documentReference as! Self
    }

    public static func unwrap(_ value: DocumentReference) throws -> DocumentReference {
        value
    }
}

@propertyWrapper
public struct Reference<D, V>: Codable, Equatable where D: SnapshotData, V: ReferenceWrappable & Codable & Equatable {

    private var value: V?
    public init(wrappedValue value: V?) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
        } else {
            value = try V.wrap(container.decode(DocumentReference.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }

    public var wrappedValue: V? {
        get { value }
        set { value = newValue }
    }

    public var projectedValue: Self {
        self
    }

    public func get(source: FirestoreSource = .default, completion: @escaping Snapshot<D>.DocumentReadResultBlock<D>) {
        guard let ref = try? value.map(V.unwrap) else {
            completion(.failure(SnapshotError.notExists))
            return
        }
        Snapshot<D>.get(ref, source: source, completion: completion)
    }

    public func listen(includeMetadataChanges: Bool = false, completion: @escaping Snapshot<D>.DocumentReadResultBlock<D>) -> ListenerRegistration? {
        guard let ref = try? value.map(V.unwrap) else {
            completion(.failure(SnapshotError.notExists))
            return nil
        }
        return Snapshot<D>.listen(ref, includeMetadataChanges: includeMetadataChanges, completion: completion)
    }
}
