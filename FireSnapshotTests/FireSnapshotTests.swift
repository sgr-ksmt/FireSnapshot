//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private struct Task: Codable {
    var name: String = "test"
    @AtomicArray var userNames: [String] = []
    var bio: DeletableField<String>? = .init(value: "Hogeeeeeeeeeeeeee!")
}

private struct User: Codable, HasTimestamps, FieldNameReferable {
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

private extension CollectionPaths {
    static let tasks = CollectionPath<Task>("tasks")
    static let users = CollectionPath<User>("users")
    static let superNestedTasks: CollectionPath<Task> = AnyCollectionPath("foo").anyDocument("bar").anyCollection("baz").anyDocument("hye").collection("tasks")
}

private extension DocumentPaths {
    static func task(taskID: String) -> DocumentPath<Task> {
        CollectionPaths.tasks.document(taskID)
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
        let taskSnapshot = Snapshot(data: .init(), path: .tasks)
        taskSnapshot.create()
        let snapshot = Snapshot(data: .init(taskRef: taskSnapshot.reference), path: .users)
        snapshot.create { result in
            switch result {
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            default:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Snapshot.get(.users, queryBuilder: {
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

        let task = Snapshot(data: .init(), path: .tasks)
        let task2 = Snapshot(data: .init(), path: .tasks)
        let user = Snapshot(data: .init(taskRef: task.reference), path: .users)

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
                let task = Snapshot(data: .init(), path: .tasks)
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

    func testAtomicArray() {
        let exp = expectation(description: #function)
        let taskSnapshot = Snapshot(data: .init(userNames: ["Mike"]), path: .tasks)
        taskSnapshot.create { result in
            switch result {
            case .success:
                taskSnapshot.data.$userNames.union(["John", "Lisa"])
                taskSnapshot.update { _ in
                    Snapshot.get(.task(taskID: taskSnapshot.reference.documentID)) { result in
                        XCTAssertEqual((try? result.get())?.data.userNames.count, 3)
                        XCTAssertEqual((try? result.get())?.data.userNames, ["Mike", "John", "Lisa"])
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

    func testDeletableField() {
        let exp = expectation(description: #function)
        let taskSnapshot = Snapshot(data: .init(), path: .tasks)
        taskSnapshot.create { result in
            switch result {
            case .success:
                taskSnapshot.data.bio?.delete()
                taskSnapshot.update { _ in
                    Snapshot.get(taskSnapshot.path) { result in
                        switch result {
                        case let .success(task):
                            XCTAssertEqual(task.data.bio?.value, nil)
                        case let .failure(error):
                            XCTFail("\(error)")
                        }
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
}
