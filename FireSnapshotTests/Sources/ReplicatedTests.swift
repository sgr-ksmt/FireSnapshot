//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
}

private struct Mock: SnapshotData, HasTimestamps, Equatable {
    var name: String = "Mike"
}

class ReplicatedTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testReplicated() {
        let mock = Snapshot(data: .init(), path: .mocks)
        let replicated = try? mock.replicated()
        XCTAssertNotNil(replicated)
        XCTAssertEqual(mock.path, replicated?.path)
        XCTAssertEqual(mock.name, replicated?.name)
        XCTAssertEqual(mock, replicated)
        mock.name = "changed"
        XCTAssertNotEqual(mock.name, replicated?.name)
    }

    func testHasTimestampReplicated() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    switch result {
                    case let .success(m):
                        XCTAssertNotNil(m.createTime)
                        XCTAssertNotNil(m.updateTime)
                        let replicated = try? m.replicated()
                        XCTAssertNotNil(replicated)
                        XCTAssertNotNil(replicated?.createTime)
                        XCTAssertNotNil(replicated?.updateTime)
                        XCTAssertEqual(m.createTime, replicated?.createTime)
                        XCTAssertEqual(m.updateTime, replicated?.updateTime)
                        XCTAssertEqual(mock, replicated)
                        XCTAssertEqual(m.path, replicated?.path)
                        XCTAssertEqual(m.name, replicated?.name)
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

    func testDifferencePathReplicated() {
        let mock = Snapshot(data: .init(), path: .mocks)
        let replicated = try? mock.replicated(path: CollectionPaths.mocks.document("replicated"))
        XCTAssertNotNil(replicated)
        XCTAssertNotEqual(mock.path, replicated?.path)
        XCTAssertEqual(mock.name, replicated?.name)
        XCTAssertNotEqual(mock, replicated)
        mock.name = "changed"
        XCTAssertNotEqual(mock.name, replicated?.name)
    }
}
