//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseStorage
import Foundation

@propertyWrapper
public struct StoragePath: Codable, Equatable {
    public var wrappedValue: StorageReference?
    public init(wrappedValue: StorageReference?) {
        self.wrappedValue = wrappedValue
    }

    public init(path: String) {
        self.wrappedValue = Storage.storage().reference().child(path)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = nil
        } else {
            wrappedValue = try Storage.storage().reference().child(container.decode(String.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue?.fullPath)
    }

    public var projectedValue: Self {
        get {
            self
        }
        set {
            self = newValue
        }
    }

    public var path: String? {
        get {
            wrappedValue?.fullPath
        }
        set {
            wrappedValue = newValue.flatMap(Storage.storage().reference().child)
        }
    }
}
