//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension WriteBatch {
    func create<D>(_ snapshot: Snapshot<D>) throws {
        var fields = try Firestore.Encoder().encode(snapshot.data)
        if snapshot.data is HasTimestamps {
            fields[SnapshotTimestampKey.createTime.rawValue] = FieldValue.serverTimestamp()
            fields[SnapshotTimestampKey.updateTime.rawValue] = FieldValue.serverTimestamp()
        }
        setData(try snapshot.extractWriteFieldsForCreate(), forDocument: snapshot.reference)
    }

    func update<D>(_ snapshot: Snapshot<D>) throws {
        updateData(try snapshot.extractWriteFieldsForUpdate(), forDocument: snapshot.reference)
    }

    func delete<D>(_ snapshot: Snapshot<D>) {
        deleteDocument(snapshot.reference)
    }
}
