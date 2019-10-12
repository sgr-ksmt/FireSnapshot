//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

extension WriteBatch {
    func create<D>(_ snapshot: Snapshot<D>) throws {
        setData(try snapshot.extractWriteFieldsForCreate(), forDocument: snapshot.reference)
    }

    func update<D>(_ snapshot: Snapshot<D>) throws {
        updateData(try snapshot.extractWriteFieldsForUpdate(), forDocument: snapshot.reference)
    }

    func delete<D>(_ snapshot: Snapshot<D>) {
        deleteDocument(snapshot.reference)
    }
}
