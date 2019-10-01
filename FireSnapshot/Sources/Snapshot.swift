//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public protocol SnapshotType {
    associatedtype Data: Codable
}

public final class Snapshot<D>: SnapshotType where D: Codable {
    public typealias Data = D
    public typealias DataFactory = (DocumentReference) -> D
    public var data: D
    public let reference: DocumentReference
    public var path: DocumentPath {
        DocumentPath(reference.path)
    }

    private var _createTime: Timestamp?
    private var _updateTime: Timestamp?

    public init(data: D, reference: DocumentReference) {
        self.reference = reference
        self.data = data
    }

    public convenience init(data: D, path: DocumentPath) {
        self.init(data: data, reference: path.documentReference)
    }

    public convenience init(dataFactory: DataFactory, path: DocumentPath) {
        let ref = path.documentReference
        self.init(data: dataFactory(ref), reference: ref)
    }

    public convenience init(data: D, path: CollectionPath, id: String? = nil) {
        self.init(data: data, reference: path.documentRefernce(id: id))
    }

    public convenience init(dataFactory: DataFactory, path: CollectionPath, id: String? = nil) {
        let ref = path.documentRefernce(id: id)
        self.init(data: dataFactory(ref), reference: ref)
    }

    public convenience init(snapshot: DocumentSnapshot) throws {
        guard let data = try snapshot.data(as: D.self) else {
            throw SnapshotError.notExists
        }

        self.init(data: data, reference: snapshot.reference)
        if data is HasTimestamps {
            _createTime = snapshot.data()?[SnapshotTimestampKey.createTime.rawValue] as? Timestamp
            _updateTime = snapshot.data()?[SnapshotTimestampKey.updateTime.rawValue] as? Timestamp
        }
    }

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

extension Snapshot: Equatable where D: Equatable {
    public static func == (lhs: Snapshot<D>, rhs: Snapshot<D>) -> Bool {
        return lhs.reference.path == rhs.reference.path
            && lhs.data == rhs.data
    }
}

public extension Snapshot where D: HasTimestamps {
    var createTime: Timestamp? {
       _createTime
    }

    var updateTime: Timestamp? {
        _createTime
    }
}
