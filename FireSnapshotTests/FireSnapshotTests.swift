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

    func testBatch() {
        let exp = expectation(description: #function)

        let task = Snapshot<Task>(data: .init(), path: CollectionPath("tasks"))
        let task2 = Snapshot<Task>(data: .init(), path: CollectionPath("tasks"))
        let user = Snapshot<User>(data: .init(taskRef: task.reference), path: CollectionPath("users"))

        task2.create { result in
            switch result {
            case .success:
                task2.data.name = "mike"
                let batch = Firestore.firestore().batch()
                try! batch.create(task)
                try! batch.create(user)
                try! batch.update(task2)
                batch.commit { error in
                    if let error = error {
                        XCTFail("\(error)")
                        exp.fulfill()
                    } else {
                        exp.fulfill()
                    }
                }

            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testTransaction() {
        let exp = expectation(description: #function)

        Firestore.firestore().runTransaction({ t, errorPointer -> Any? in
            do {
                let task = Snapshot<Task>(data: .init(), path: CollectionPath("tasks"))
                try t.create(task)
            } catch {
                errorPointer?.pointee = error as NSError
            }
            return nil
        }) { result, error in
            if let error = error {
                XCTFail("\(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10.0)
    }
}
