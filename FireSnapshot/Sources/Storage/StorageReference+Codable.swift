//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestoreSwift
import FirebaseStorage

private protocol CodableStorageReference: Codable {}
extension CodableStorageReference {
    public init(from decoder: Decoder) throws {
        throw FirestoreDecodingError.decodingIsNotSupported(
            "StorageReference values can only be decoded with Firestore.Decoder"
        )
    }

    public func encode(to encoder: Encoder) throws {
        throw FirestoreEncodingError.encodingIsNotSupported(
            "StorageReference values can only be encoded with Firestore.Encoder"
        )
    }
}

extension StorageReference: CodableStorageReference {}
