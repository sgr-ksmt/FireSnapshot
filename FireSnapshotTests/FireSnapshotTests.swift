//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

struct Task: Codable {
    var name: String = "test"
}

struct User: Codable, HasTimestamps, FieldNameReferable {
    var id: SelfDocumentID = .init()
    var name: String = "google"
    @IncrementableInt var count: Int64 = 10
    @IncrementableDouble var alpha: Double = 0.2
    @Reference<Task> var taskRef: DocumentReference
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
        let taskSnapshot = Snapshot<Task>(data: .init(), path: CollectionPath("tasks"))
        taskSnapshot.create()
        let snapshot = Snapshot<User>(data: .init(taskRef: taskSnapshot.reference), path: CollectionPath("users"))
        snapshot.create { result in
            switch result {
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            default:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Snapshot<User>.get(CollectionPath("users"), queryBuilder: {
                        QueryBuilder<User>($0)
                            .where(.createTime, isLessThanOrEqualTo: Date())
                            .generate()
                    }) { result in
                        XCTAssertEqual((try? result.get())?.count, 1)
                        exp.fulfill()
                    }
//                    Snapshot<User>.get(snapshot.path) { result in
//                        switch result {
//                        case let .success(user):
//                            XCTAssertEqual(user.data.id.id, snapshot.reference.documentID)
//                            XCTAssertEqual(user.data.taskRef.path, taskSnapshot.reference.path)
//                            user.data.$taskRef.get { result in
//                                XCTAssertEqual((try? result.get())?.data.name, "test")
//                                exp.fulfill()
//                            }
//                        case let .failure(error):
//                            XCTFail("\(error)")
//                            exp.fulfill()
//                        }
//                    }
                }
            }
        }
        wait(for: [exp], timeout: 10.0)
    }
}
