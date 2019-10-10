//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
    static let invalids = CollectionPath<Mock>("invalid")
    static func groups(for mock: DocumentPath<Mock>) -> CollectionPath<Group> {
        mock.collection("groups")
    }
}

private struct Mock: SnapshotData, HasTimestamps {
    var name: String = ""
    var bio: String? = ""
}

private struct Group: SnapshotData {
    var name: String = ""
}

class WriteTest: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testCreate() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.create { result in
            switch result {
            case .success:
                exp.fulfill()
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testCreateFailed() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .invalids)
        mock.create { result in
            switch result {
            case .success:
                XCTFail()
                exp.fulfill()
            case let .failure(error):
                XCTAssertEqual(error._code, 7)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testMergeToSameDocument() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.bio = "exists"
        mock.create { result in
            switch result {
            case .success:
                let m = try! mock.replicated()
                m.name = "merged"
                m.bio = nil
                m.merge { result in
                    switch result {
                    case .success:
                        Snapshot.get(mock.path) { result in
                            switch result {
                            case let .success(m):
                                XCTAssertEqual(m.name, "merged")
                                XCTAssertNotNil(m.bio)
                                XCTAssertEqual(m.bio, "exists")
                                exp.fulfill()
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

    func testCreateSubCollection() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.create { result in
            switch result {
            case .success:
                let group = Snapshot(data: Group(), path: .groups(for: mock.path))
                group.create { result in
                    switch result {
                    case .success:
                            exp.fulfill()
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

    func testUpdate() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    switch result {
                    case let .success(m):
                        m.name = "changed"
                        m.update { result in
                            switch result {
                            case .success:
                                Snapshot.get(mock.path) { result in
                                    XCTAssertEqual((try? result.get())?.name, "changed")
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

    func testUpdateFailed() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.update { result in
            switch result {
            case .success:
                XCTFail()
                exp.fulfill()
            case let .failure(error):
                XCTAssertEqual(error._code, 5)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testDelete() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    switch result {
                    case let .success(m):
                        m.delete { result in
                            switch result {
                            case .success:
                                Snapshot.get(mock.path) { result in
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
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }
}
