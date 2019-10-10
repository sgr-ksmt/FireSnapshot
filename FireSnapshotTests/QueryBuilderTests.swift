//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
}

private struct Mock: SnapshotData, FieldNameReferable {
    var count: Int = 0
    var name: String = ""
    var noRef: String = ""

    static var fieldNames: [PartialKeyPath<Mock> : String] {
        [
            \Self.self.name: "name",
            \Self.self.count: "count"
        ]
    }
}

class QueryBuilderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testQueryBuilderStack() {
        do {
            let qb = QueryBuilder<Mock>(CollectionPaths.mocks.collectionReference)
                .where(\.name, isEqualTo: "")
                .where(\.count, isEqualTo: 0)

            XCTAssertEqual(qb.call, 2)
            XCTAssertEqual(qb.stack, 2)
        }

        do {
            let qb = QueryBuilder<Mock>(CollectionPaths.mocks.collectionReference)
                .where(\.name, isEqualTo: "")
                .where(\.count, isEqualTo: 0)
                .where(\.noRef, isEqualTo: "")

            XCTAssertEqual(qb.call, 3)
            XCTAssertEqual(qb.stack, 2)
        }

        do {
            let qb = QueryBuilder<Mock>(CollectionPaths.mocks.collectionReference)
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")
                .where(\.name, isEqualTo: "")

            XCTAssertEqual(qb.call, 10)
            XCTAssertEqual(qb.stack, 10)
        }
    }
}
