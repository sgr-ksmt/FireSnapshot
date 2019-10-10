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

    func testAnyDocumentPath() {
        XCTAssertTrue(AnyDocumentPath("mocks/xxx").isValid)
        XCTAssertTrue(AnyDocumentPath("mocks/xxx/sub/yyy").isValid)
        XCTAssertTrue(AnyCollectionPath("mocks").anyDocument("xxx").isValid)
        XCTAssertTrue(AnyCollectionPath("mocks").anyDocument("xxx").anyCollection("sub").anyDocument("yyy").isValid)

        XCTAssertFalse(AnyDocumentPath("").isValid)
        XCTAssertFalse(AnyDocumentPath("/").isValid)
        XCTAssertFalse(AnyDocumentPath("///").isValid)
        XCTAssertFalse(AnyDocumentPath("/xxx").isValid)
        XCTAssertFalse(AnyDocumentPath("//xxx").isValid)
        XCTAssertFalse(AnyDocumentPath("mocks").isValid)
        XCTAssertFalse(AnyDocumentPath("mocks/").isValid)
        XCTAssertFalse(AnyDocumentPath("mocks//").isValid)
        XCTAssertFalse(AnyDocumentPath("mocks/xxx/sub").isValid)
        XCTAssertFalse(AnyDocumentPath("mocks/xxx//yyy").isValid)
        XCTAssertFalse(AnyDocumentPath("mocks//sub").isValid)
        XCTAssertFalse(AnyDocumentPath("mocks//sub/yyy").isValid)

        XCTAssertEqual(AnyDocumentPath("mocks/xxx"), AnyDocumentPath("mocks/xxx"))
        XCTAssertNotEqual(AnyDocumentPath("mocks/xxx"), AnyDocumentPath("mocks/yyy"))
    }

    func testAnyCollectionPath() {
        XCTAssertTrue(AnyCollectionPath("mocks").isValid)
        XCTAssertTrue(AnyCollectionPath("mocks/xxx/sub").isValid)
        XCTAssertTrue(AnyCollectionPath("mocks").anyDocument("xxx").anyCollection("sub").isValid)

        XCTAssertFalse(AnyCollectionPath("").isValid)
        XCTAssertFalse(AnyCollectionPath("/").isValid)
        XCTAssertFalse(AnyCollectionPath("///").isValid)
        XCTAssertFalse(AnyCollectionPath("mocks/xxx").isValid)
        XCTAssertFalse(AnyCollectionPath("/xxx").isValid)
        XCTAssertFalse(AnyCollectionPath("mocks/xxx/sub/yyy").isValid)
        XCTAssertFalse(AnyCollectionPath("mocks/xxx//yyy").isValid)
        XCTAssertFalse(AnyCollectionPath("mocks//yyy").isValid)

        XCTAssertEqual(AnyCollectionPath("mocks"), AnyCollectionPath("mocks"))
        XCTAssertNotEqual(AnyCollectionPath("mocks1"), AnyCollectionPath("mocks2"))
    }
}
