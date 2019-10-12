//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
}

private struct Mock: SnapshotData, HasTimestamps {
    var name: String = "Mike"
}
class DocumentTimestampsTests: XCTestCase {

    override func setUp() {
        super.setUp()
         FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testUpdateTimeChanged() {
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
                        XCTAssertEqual(m.createTime, m.updateTime)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            m.update { result in
                                switch result {
                                case .success:
                                    Snapshot.get(mock.path) { result in
                                        switch result {
                                        case let .success(m):
                                            XCTAssertNotNil(m.createTime)
                                            XCTAssertNotNil(m.updateTime)
                                            XCTAssertNotEqual(m.createTime, m.updateTime)
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
