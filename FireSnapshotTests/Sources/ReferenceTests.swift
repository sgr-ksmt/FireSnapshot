//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let tasks = CollectionPath<Task>("tasks")
    static let users = CollectionPath<User>("users")
}

private struct User: SnapshotData {
    var name: String = "Mike"
}

private struct Task: SnapshotData {
    var title: String
    @Reference<User> var author = nil
}

class ReferenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testGetReference() {
        let exp = expectation(description: #function)
        let user = Snapshot(data: .init(), path: .users)
        user.create { result in
            switch result {
            case .success:
                let task = Snapshot(data: .init(title: "task"), path: .tasks)
                task.author = user.reference
                task.create { result in
                    switch result {
                    case .success:
                        Snapshot.get(task.path) { result in
                            switch result {
                            case let .success(t):
                                t.$author.get { result in
                                    XCTAssertEqual((try? result.get())?.name, user.name)
                                    exp.fulfill()
                                }
                            case let .failure(error):
                                XCTFail("\(error)")
                                exp.fulfill()
                            }
                        }
                    case let .failure(error):
                        XCTFail("\(error)")
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

    func testGetReferenceFailed() {
        let exp = expectation(description: #function)
        let user = Snapshot(data: .init(), path: .users)
        user.create { result in
            switch result {
            case .success:
                let task = Snapshot(data: .init(title: "task"), path: .tasks)
                task.author = CollectionPaths.users.document("xxx").documentReference
                task.create { result in
                    switch result {
                    case .success:
                        Snapshot.get(task.path) { result in
                            switch result {
                            case let .success(t):
                                t.$author.get { result in
                                    switch result {
                                    case .success:
                                        XCTFail()
                                        exp.fulfill()
                                    case .failure:
                                        exp.fulfill()
                                    }
                                }
                            case let .failure(error):
                                XCTFail("\(error)")
                                exp.fulfill()
                            }
                        }
                    case let .failure(error):
                        XCTFail("\(error)")
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

    func testEmptyReferenceError() {
        let exp = expectation(description: #function)
        let task = Snapshot(data: .init(title: "task"), path: .tasks)
        task.create { result in
            switch result {
            case .success:
                Snapshot.get(task.path) { result in
                    switch result {
                    case let .success(task):
                        task.$author.get { result in
                            switch result {
                            case .success:
                                XCTFail()
                                exp.fulfill()
                            case let .failure(error):
                                XCTAssertEqual(error as? SnapshotError, SnapshotError.notExists)
                                exp.fulfill()
                            }
                        }
                    case let .failure(error):
                        XCTFail("\(error)")
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
