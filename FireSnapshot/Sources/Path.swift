//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public protocol FirestorePath: Equatable {
    var path: String { get }
    init(_ path: String)
    func verify() -> Bool
}

public struct DocumentPath: FirestorePath {
    public let path: String

    init(_ collectionPath: CollectionPath, _ documentID: String) {
        self.init([collectionPath.path, documentID].joined(separator: "/"))
    }

    public init(_ path: String) {
        self.path = path
    }

    public func collection(_ collectionName: String) -> CollectionPath {
        CollectionPath(self, collectionName)
    }

    public func verify() -> Bool {
        let components = path.components(separatedBy: "/")
        let isValid = components.count % 2 == 0 && !components.last!.isEmpty
        return isValid
    }

    public var documentReference: DocumentReference {
        Firestore.firestore().document(path)
    }
}

public struct CollectionPath: FirestorePath {
    public let path: String

    public init(_ documentPath: DocumentPath, _ collectionName: String) {
        self.init([documentPath.path, collectionName].joined(separator: "/"))
    }

    public init(_ path: String) {
        self.path = path
    }

    public func doc(_ documentID: String) -> DocumentPath {
        DocumentPath(self, documentID)
    }

    public func verify() -> Bool {
        let components = path.components(separatedBy: "/")
        let isValid = components.count % 2 == 1 && !components.last!.isEmpty
        return isValid
    }

    public var collectionReference: CollectionReference {
        Firestore.firestore().collection(path)
    }

    public func documentRefernce(id: String? = nil) -> DocumentReference {
        if let id = id, !id.isEmpty {
            return Firestore.firestore().collection(path).document(id)
        } else {
            return Firestore.firestore().collection(path).document()
        }
    }
}
