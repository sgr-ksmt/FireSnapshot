//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseStorage
import Foundation

public protocol StorageReferenceWrappable {
    static func wrap(_ storageReference: StorageReference) throws -> Self
    static func unwrap(_ value: Self) throws -> StorageReference
}

extension String: StorageReferenceWrappable {
    public static func wrap(_ storageReference: StorageReference) throws -> Self {
        storageReference.fullPath
    }

    public static func unwrap(_ value: Self) throws -> StorageReference {
        Storage.storage().reference().child(value)
    }
}

extension StorageReference: StorageReferenceWrappable {
    public static func wrap(_ storageReference: StorageReference) throws -> Self {
        storageReference as! Self
    }

    public static func unwrap(_ value: StorageReference) throws -> StorageReference {
        value
    }
}

@propertyWrapper
public struct StoragePath<V>: Codable, Equatable where V: StorageReferenceWrappable & Codable & Equatable {
    var value: V?
    public init(wrappedValue value: V?) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
        } else {
            value = try V.wrap(Storage.storage().reference().child(container.decode(String.self)))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.map(V.unwrap)?.fullPath)
    }


    public var wrappedValue: V? {
        get { value }
        set { value = newValue }
    }

    public var projectedValue: StorageReference? {
        try? value.map(V.unwrap)
    }
}
