//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public protocol SnapshotType {
    associatedtype Data: SnapshotData
    var reference: DocumentReference { get }
    var data: Data { get }
}

public extension SnapshotType {
    func extractWriteFieldsForCreate() throws -> [String: Any] {
        var fields = try Firestore.Encoder().encode(data)
        if data is HasTimestamps {
            fields[SnapshotTimestampKey.createTime.rawValue] = FieldValue.serverTimestamp()
            fields[SnapshotTimestampKey.updateTime.rawValue] = FieldValue.serverTimestamp()
        }
        return fields
    }

    func extractWriteFieldsForUpdate() throws -> [String: Any] {
        var fields = try Firestore.Encoder().encode(data)
        if data is HasTimestamps {
            fields[SnapshotTimestampKey.updateTime.rawValue] = FieldValue.serverTimestamp()
        }
        return fields
    }
}
