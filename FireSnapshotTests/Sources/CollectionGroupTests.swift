//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let users = CollectionPath<User>("users")
    static let tasks = CollectionPath<Task>("tasks")
    static func groups(for user: DocumentPath<User>) -> CollectionPath<Group> {
        user.collection("groups")
    }

    static func groups(for task: DocumentPath<Task>) -> CollectionPath<Group> {
        task.collection("groups")
    }
}

private extension CollectionGroups {
    static let groups = CollectionGroup<Group>("groups")
}

private struct User: SnapshotData {
    var name: String = "Mike"
}

private struct Task: SnapshotData {
    var title: String = "task"
}

private struct Group: SnapshotData {
    var name: String = "group"
}

class CollectionGroupTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testCollectionGroup() {
        let exp = expectation(description: #function)

        let user = Snapshot(data: .init(), path: .users)
        let task = Snapshot(data: .init(), path: .tasks)

        let batch = Batch()
            .create(user)
            .create(task)
        batch.commit { error in
            if let error = error {
                XCTFail("\(error)")
                exp.fulfill()
                return
            }
            let g1 = Snapshot(data: .init(), path: .groups(for: user.path))
            g1.name = "from user"
            let g2 = Snapshot(data: .init(), path: .groups(for: task.path))
            g2.name = "from task"
            let batch = Batch()
                .create(g1)
                .create(g2)

            batch.commit { error in
                if let error = error {
                    XCTFail("\(error)")
                    exp.fulfill()
                    return
                }
                Snapshot.get(collectionGroup: .groups) { result in
                    switch result {
                    case let .success(groups):
                        XCTAssertEqual(groups.count, 2)
                        exp.fulfill()
                    case let .failure(error):
                        XCTFail("\(error)")
                        exp.fulfill()
                    }
                }
            }
        }
        wait(for: [exp], timeout: 10.0)
    }
}
