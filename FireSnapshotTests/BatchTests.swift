//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let users = CollectionPath<User>("users")
    static let tasks = CollectionPath<Task>("tasks")
    static let mocks = CollectionPath<Mock>("mocks")
    static let invalids = CollectionPath<Invalid>("invalids")
}

private struct User: SnapshotData {
    var name: String = "Mike"
}

private struct Task: SnapshotData {
    var title: String = "task"
}

private struct Mock: SnapshotData {
    var count: Int = 0
}

private struct Invalid: SnapshotData {
    var name: String = ""
}

class BatchTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testSuccessWrite() {
        let exp = expectation(description: #function)
        let user = Snapshot(data: .init(), path: .users)
        let task = Snapshot(data: .init(), path: .tasks)

        let batch = Firestore.firestore().batch()
        try! batch.create(user)
        try! batch.create(task)

        batch.commit { error in
            if error != nil {
                XCTFail()
            }
            let mock = Snapshot(data: .init(), path: .mocks)

            let batch = Firestore.firestore().batch()
            user.name = "John"
            try! batch.update(user)
            batch.delete(task)
            try! batch.create(mock)

            batch.commit { error in
                if error != nil {
                    XCTFail()
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testFailWrite() {
        let exp = expectation(description: #function)
        let user = Snapshot(data: .init(), path: .users)
        let invalid = Snapshot(data: .init(), path: .invalids)

        let batch = Firestore.firestore().batch()
        try! batch.create(user)
        try! batch.create(invalid)

        batch.commit { error in
            if error == nil {
                XCTFail("commit should be failed.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }
}
