//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
    static let invalids = CollectionPath<Mock>("invalids")
}

private struct Mock: SnapshotData {
    var name: String = "mock"
}

class ReadTests: XCTestCase {

    override func setUp() {
        super.setUp()
         FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testGetDocument() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 3

        Snapshot.get(CollectionPaths.mocks.document("xxxx")) { result in
            switch result {
            case .success:
                XCTFail()
                exp.fulfill()
            case let .failure(error):
                XCTAssertEqual(error as? SnapshotError, SnapshotError.notExists)
                exp.fulfill()
            }
        }

        Snapshot.get(CollectionPaths.invalids.document("xxxx")) { result in
            switch result {
            case .success:
                XCTFail()
                exp.fulfill()
            case let .failure(error):
                XCTAssertEqual(error._code, 7)
                exp.fulfill()
            }
        }


        let mock = Snapshot(data: .init(), path: .mocks)
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    XCTAssertEqual((try? result.get())?.name, "mock")
                    exp.fulfill()
                }
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testGetDocuments() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 2

        Snapshot.get(.mocks) { result in
            switch result {
            case let .success(mocks):
                XCTAssertTrue(mocks.isEmpty)

                let mock = Snapshot(data: .init(), path: .mocks)
                mock.create { result in
                    switch result {
                    case .success:
                        Snapshot.get(.mocks) { result in
                            XCTAssertEqual((try? result.get())?.count, 1)
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

        Snapshot.get(.invalids) { result in
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

    func testListenDocument() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 4

        _ = Snapshot.listen(CollectionPaths.mocks.document("xxxx")) { result in
            switch result {
            case .success:
                XCTFail()
                exp.fulfill()
            case let .failure(error):
                XCTAssertEqual(error as? SnapshotError, SnapshotError.notExists)
                exp.fulfill()
            }
        }

        _ = Snapshot.listen(CollectionPaths.invalids.document("xxxx")) { result in
            switch result {
            case .success:
                XCTFail()
                exp.fulfill()
            case let .failure(error):
                XCTAssertEqual(error._code, 7)
                exp.fulfill()
            }
        }


        let mock = Snapshot(data: .init(), path: .mocks)
        var names = [String?]()
        mock.create { result in
            switch result {
            case .success:
                _ = Snapshot.listen(mock.path) { result in
                    names.append((try? result.get())?.name)
                    exp.fulfill()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    mock.name = "changed"
                    mock.update()
                }
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
        XCTAssertEqual(names, ["mock", "changed"])
    }

    func testListenDocuments() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 3
        var counts = [Int]()
        _ = Snapshot.listen(.mocks) { result in
            switch result {
            case let .success(mocks):
                counts.append(mocks.count)
                exp.fulfill()
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let mock = Snapshot(data: .init(), path: .mocks)
            mock.create()
        }

        _ = Snapshot.listen(.invalids) { result in
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
        XCTAssertEqual(counts, [0, 1])
    }

}
