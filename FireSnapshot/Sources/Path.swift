//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public class DocumentPaths {
    fileprivate init() {
    }
}

public class CollectionPaths {
    fileprivate init() {
    }
}


public protocol FirestorePath: Hashable {
    var path: String { get }
    init(_ path: String)
    var isValid: Bool { get }
}

enum PathLength: Int {
    case even
    case odd
}

extension FirestorePath {
    func isValid(_ pathLength: PathLength) -> Bool {
        let components = path.components(separatedBy: "/")
        return !components.isEmpty
            && components.count % 2 == pathLength.rawValue
            && components.allSatisfy { !$0.isEmpty }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

extension FirestorePath where Self: DocumentPaths {
    public var isValid: Bool {
        isValid(.even)
    }
}

extension FirestorePath where Self: CollectionPaths {
    public var isValid: Bool {
        isValid(.odd)
    }
}

public class DocumentPath<T>: DocumentPaths, FirestorePath where T: SnapshotData {
    public let path: String

    fileprivate convenience init(_ collectionPath: String, _ documentID: String) {
        self.init([collectionPath, documentID].joined(separator: "/"))
    }

    fileprivate convenience init<U>(_ collectionPath: CollectionPath<U>, _ documentID: String) where U: SnapshotData {
        self.init(collectionPath.path, documentID)
    }

    required public init(_ path: String) {
        self.path = path
    }

    public func collection(_ collectionName: String) -> CollectionPath<T> {
        CollectionPath(self, collectionName)
    }

    public func collection<U>(_ collectionName: String) -> CollectionPath<U> where U: SnapshotData {
        CollectionPath(self, collectionName)
    }

    public var documentReference: DocumentReference {
        Firestore.firestore().document(path)
    }

    public static func == (lhs: DocumentPath<T>, rhs: DocumentPath<T>) -> Bool {
        lhs.path == rhs.path
    }
}

public class CollectionPath<T>: CollectionPaths, FirestorePath where T: SnapshotData {
    public let path: String

    fileprivate convenience init(_ documentPath: String, _ collectionName: String) {
        self.init([documentPath, collectionName].joined(separator: "/"))
    }

    fileprivate convenience init<U>(_ documentPath: DocumentPath<U>, _ collectionName: String) where U: SnapshotData {
        self.init(documentPath.path, collectionName)
    }

    required public init(_ path: String) {
        self.path = path
    }

    public func document(_ documentID: String) -> DocumentPath<T> {
        DocumentPath(self, documentID)
    }

    public func document<U>(_ documentID: String) -> DocumentPath<U> where U: SnapshotData {
        DocumentPath(self, documentID)
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

    public static func == (lhs: CollectionPath<T>, rhs: CollectionPath<T>) -> Bool {
        lhs.path == rhs.path
    }
}

public class AnyDocumentPath: DocumentPaths, FirestorePath {
    public let path: String

    fileprivate convenience init(_ collectionPath: String, _ documentID: String) {
        self.init([collectionPath, documentID].joined(separator: "/"))
    }

    fileprivate convenience init<T>(_ collectionPath: CollectionPath<T>, _ documentID: String) where T: SnapshotData {
        self.init(collectionPath.path, documentID)
    }

    public required init(_ path: String) {
        self.path = path
    }

    public convenience init<T>(_ path: DocumentPath<T>) {
        self.init(path.path)
    }

    public func anyCollection(_ collectionName: String) -> AnyCollectionPath {
        AnyCollectionPath(self.path, collectionName)
    }

    public func collection<T>(_ collectionName: String) -> CollectionPath<T> where T: SnapshotData {
        CollectionPath(self.path, collectionName)
    }

    public static func == (lhs: AnyDocumentPath, rhs: AnyDocumentPath) -> Bool {
        lhs.path == rhs.path
    }
}

public class AnyCollectionPath: CollectionPaths, FirestorePath {
    public let path: String

    fileprivate convenience init(_ documentPath: String, _ collectionName: String) {
        self.init([documentPath, collectionName].joined(separator: "/"))
    }

    fileprivate convenience init<T>(_ documentPath: DocumentPath<T>, _ collectionName: String) where T: SnapshotData {
        self.init(documentPath.path, collectionName)
    }

    public required init(_ path: String) {
        self.path = path
    }
    
    public convenience init<T>(_ path: CollectionPath<T>) {
        self.init(path.path)
    }

    public func anyDocument(_ documentID: String) -> AnyDocumentPath {
        AnyDocumentPath(self.path, documentID)
    }

    public func document<T>(_ documentID: String) -> DocumentPath<T> where T: SnapshotData {
        DocumentPath(self.path, documentID)
    }

    public static func == (lhs: AnyCollectionPath, rhs: AnyCollectionPath) -> Bool {
        lhs.path == rhs.path
    }
}
