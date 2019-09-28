//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

struct User: Codable, HasTimestamps, FieldNameReferable {
    var id: SelfDocumentID = .init()
    var name: String = "google"
    @IncrementableInt var count: Int64 = 10
    @IncrementableDouble var alpha: Double = 0.2

    static var fieldNames: [PartialKeyPath<User>: String] {
        [
            \User.name: "name",
            \User.count: "count"
        ]
    }
}

class FireSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testExample() {
        let exp = expectation(description: #function)
        let snapshot = Snapshot<User>(data: .init(), path: CollectionPath("users"))
        snapshot.create { result in
            switch result {
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            default:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Snapshot<User>.get(snapshot.path) { result in
                        XCTAssertEqual((try? result.get())?.data.id.id, snapshot.reference.documentID)
                        exp.fulfill()
                    }
                }
            }
        }
        wait(for: [exp], timeout: 10.0)
    }
}
