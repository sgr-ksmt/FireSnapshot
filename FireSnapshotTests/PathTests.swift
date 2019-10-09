//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private struct Mock: SnapshotData {
}

class PathTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDocumentPath() {
        XCTAssertTrue(DocumentPath<Mock>("mocks/xxx").isValid)
        XCTAssertTrue(DocumentPath<Mock>("mocks/xxx/sub/yyy").isValid)
        XCTAssertTrue(CollectionPath<Mock>("mocks").document("xxx").isValid)
        XCTAssertTrue(CollectionPath<Mock>("mocks").document("xxx").collection("sub").document("yyy").isValid)

        XCTAssertFalse(DocumentPath<Mock>("").isValid)
        XCTAssertFalse(DocumentPath<Mock>("/").isValid)
        XCTAssertFalse(DocumentPath<Mock>("///").isValid)
        XCTAssertFalse(DocumentPath<Mock>("/xxx").isValid)
        XCTAssertFalse(DocumentPath<Mock>("//xxx").isValid)
        XCTAssertFalse(DocumentPath<Mock>("mocks").isValid)
        XCTAssertFalse(DocumentPath<Mock>("mocks/").isValid)
        XCTAssertFalse(DocumentPath<Mock>("mocks//").isValid)
        XCTAssertFalse(DocumentPath<Mock>("mocks/xxx/sub").isValid)
        XCTAssertFalse(DocumentPath<Mock>("mocks/xxx//yyy").isValid)
        XCTAssertFalse(DocumentPath<Mock>("mocks//sub").isValid)
        XCTAssertFalse(DocumentPath<Mock>("mocks//sub/yyy").isValid)

        XCTAssertEqual(DocumentPath<Mock>("mocks/xxx"), DocumentPath<Mock>("mocks/xxx"))
        XCTAssertNotEqual(DocumentPath<Mock>("mocks/xxx"), DocumentPath<Mock>("mocks/yyy"))
    }

    func testCollectionPath() {
        XCTAssertTrue(CollectionPath<Mock>("mocks").isValid)
        XCTAssertTrue(CollectionPath<Mock>("mocks/xxx/sub").isValid)
        XCTAssertTrue(CollectionPath<Mock>("mocks").document("xxx").collection("sub").isValid)

        XCTAssertFalse(CollectionPath<Mock>("").isValid)
        XCTAssertFalse(CollectionPath<Mock>("/").isValid)
        XCTAssertFalse(CollectionPath<Mock>("///").isValid)
        XCTAssertFalse(CollectionPath<Mock>("mocks/xxx").isValid)
        XCTAssertFalse(CollectionPath<Mock>("/xxx").isValid)
        XCTAssertFalse(CollectionPath<Mock>("mocks/xxx/sub/yyy").isValid)
        XCTAssertFalse(CollectionPath<Mock>("mocks/xxx//yyy").isValid)
        XCTAssertFalse(CollectionPath<Mock>("mocks//yyy").isValid)

        XCTAssertEqual(CollectionPath<Mock>("mocks"), CollectionPath<Mock>("mocks"))
        XCTAssertNotEqual(CollectionPath<Mock>("mocks1"), CollectionPath<Mock>("mocks2"))
    }
}
