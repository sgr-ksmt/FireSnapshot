//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public extension DocumentReference {
    static func dummy() -> DocumentReference {
        Firestore.firestore().document("")
    }
}
