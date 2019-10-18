//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public class CollectionGroups {
    fileprivate init() {
    }
}

public class CollectionGroup<T>: CollectionGroups where T: SnapshotData {
    public let collectionID: String
    public init(_ collectionID: String) {
        self.collectionID = collectionID
        super.init()
    }

    public var query: Query {
        return Firestore.firestore().collectionGroup(collectionID)
    }
}
