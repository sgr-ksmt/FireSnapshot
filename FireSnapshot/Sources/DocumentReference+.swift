//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public extension DocumentReference {
    static func dummy() -> DocumentReference {
        Firestore.firestore().document("")
    }
}
