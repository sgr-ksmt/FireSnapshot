//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension WriteBatch {
    func set<D>(_ snapshot: Snapshot<D>) throws {
        var fields = try Firestore.Encoder().encode(snapshot.data)
        if snapshot.data is HasTimestamps {
            fields[HasTimestampsKeys.createTime] = FieldValue.serverTimestamp()
            fields[HasTimestampsKeys.updateTime] = FieldValue.serverTimestamp()
        }
        setData(fields, forDocument: snapshot.reference)
    }

    func update<D>(_ snapshot: Snapshot<D>) throws {
        var fields = try Firestore.Encoder().encode(snapshot.data)
        if snapshot.data is HasTimestamps {
            fields[HasTimestampsKeys.updateTime] = FieldValue.serverTimestamp()
        }
        updateData(fields, forDocument: snapshot.reference)
    }

    func delete<D>(_ snapshot: Snapshot<D>) {
        deleteDocument(snapshot.reference)
    }
}
