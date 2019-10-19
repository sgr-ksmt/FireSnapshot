//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
}

private struct Mock: SnapshotData, HasTimestamps {
    @StoragePath(path: "path/to/image.jpg") var imageRef
}

class StoragePathTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testCodable() {
        let mock = Mock()
        XCTAssertEqual(mock.imageRef, Storage.storage().reference().child("path/to/image.jpg"))
        let fields = try? Firestore.Encoder().encode(mock)
        XCTAssertNotNil(fields)
        XCTAssertEqual(fields?["imageRef"] as? String, "path/to/image.jpg")

        let decoded = fields.flatMap { try? Firestore.Decoder().decode(Mock.self, from: $0) }
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.imageRef, mock.imageRef)
    }

    func testPath() {
        var mock = Mock()
        XCTAssertEqual(mock.imageRef, Storage.storage().reference().child("path/to/image.jpg"))

        mock.$imageRef.path = "path/to/video.mp4"
        XCTAssertEqual(mock.imageRef, Storage.storage().reference().child("path/to/video.mp4"))
    }
}
