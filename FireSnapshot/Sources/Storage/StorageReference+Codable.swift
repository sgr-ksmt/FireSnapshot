//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseStorage

private protocol CodableStorageReference: Codable {}
extension CodableStorageReference {
    public init(from decoder: Decoder) throws {
        throw FirestoreDecodingError.decodingIsNotSupported
    }
    
    public func encode(to encoder: Encoder) throws {
        throw FirestoreEncodingError.encodingIsNotSupported
    }
}

extension StorageReference: CodableStorageReference {}
