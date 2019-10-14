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
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func test() {
        // DocumentPath
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

        XCTAssertEqual(DocumentPath<Mock>("mocks/xxx").documentReference, Firestore.firestore().document("mocks/xxx"))
        XCTAssertEqual(DocumentPath<Mock>("mocks/xxx/sub/yyy").documentReference, Firestore.firestore().document("mocks/xxx/sub/yyy"))
        XCTAssertEqual(DocumentPath<Mock>("mocks/xxx").id, "xxx")
        XCTAssertEqual(DocumentPath<Mock>("mocks/xxx/sub/yyy").id, "yyy")

        XCTAssertEqual(DocumentPath<Mock>("mocks/xxx").sameIDSubDocument("sub").path, "mocks/xxx/sub/xxx")

        // ==========================================
        // CollectionPath

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

        XCTAssertEqual(CollectionPath<Mock>("mocks").collectionReference, Firestore.firestore().collection("mocks"))
        XCTAssertEqual(CollectionPath<Mock>("mocks/xxx/sub").collectionReference, Firestore.firestore().collection("mocks/xxx/sub"))
        XCTAssertEqual(CollectionPath<Mock>("mocks").id, "mocks")
        XCTAssertEqual(CollectionPath<Mock>("mocks/xxx/sub").id, "sub")

        XCTAssertTrue(AnyDocumentPath("mocks/xxx").isValid)
        XCTAssertTrue(AnyDocumentPath("mocks/xxx/sub/yyy").isValid)
        XCTAssertTrue(AnyCollectionPath("mocks").anyDocument("xxx").isValid)
        XCTAssertTrue(AnyCollectionPath("mocks").anyDocument("xxx").anyCollection("sub").anyDocument("yyy").isValid)

        // ==========================================
        // AnyDocumentPath

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

        XCTAssertEqual(AnyDocumentPath("mocks/xxx").documentReference, Firestore.firestore().document("mocks/xxx"))
        XCTAssertEqual(AnyDocumentPath("mocks/xxx/sub/yyy").documentReference, Firestore.firestore().document("mocks/xxx/sub/yyy"))
        XCTAssertEqual(AnyDocumentPath("mocks/xxx").id, "xxx")
        XCTAssertEqual(AnyDocumentPath("mocks/xxx/sub/yyy").id, "yyy")

        XCTAssertEqual(AnyDocumentPath("mocks/xxx").anySameIDSubDocument("sub").path, "mocks/xxx/sub/xxx")

        // ==========================================
        // AnyCollectionPath

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

        XCTAssertEqual(AnyCollectionPath("mocks").collectionReference, Firestore.firestore().collection("mocks"))
        XCTAssertEqual(AnyCollectionPath("mocks/xxx/sub").collectionReference, Firestore.firestore().collection("mocks/xxx/sub"))
        XCTAssertEqual(AnyCollectionPath("mocks").id, "mocks")
        XCTAssertEqual(AnyCollectionPath("mocks/xxx/sub").id, "sub")
    }
}
