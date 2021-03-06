//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
}

private struct Mock: SnapshotData {
    @IncrementableInt var count: Int64 = 5
    @IncrementableDouble var distance: Double = 5.0
}

class IncrementableNumberTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testUpdate() {
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 2
        let mock1 = Snapshot(data: .init(), path: .mocks)
        let mock2 = Snapshot(data: .init(), path: .mocks)
        let batch = Batch()
            .create(mock1)
            .create(mock2)

        batch.commit { error in
            if let error = error {
                XCTFail("\(error)")
                exp.fulfill()
                return
            }

            Snapshot.get(mock1.path) { result in
                switch result {
                case let .success(mock):
                    XCTAssertEqual(mock.count, 5)
                    mock.$count.increment(10)
                    XCTAssertEqual(mock.count, 15)
                    XCTAssertEqual(mock.$count.incrementValue, 10)
                    mock.update { result in
                        switch result {
                        case .success:
                            Snapshot.get(mock1.path) { result in
                                XCTAssertEqual((try? result.get())?.count, 15)
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

            Snapshot.get(mock2.path) { result in
                switch result {
                case let .success(mock):
                    XCTAssertEqual(mock.distance, 5.0)
                    mock.$distance.increment(10.0)
                    XCTAssertEqual(mock.distance, 15.0)
                    XCTAssertEqual(mock.$distance.incrementValue, 10.0)
                    mock.update { result in
                        switch result {
                        case .success:
                            Snapshot.get(mock2.path) { result in
                                XCTAssertEqual((try? result.get())?.distance, 15.0)
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
        }

        wait(for: [exp], timeout: 10.0)
    }

    func testIncrementableNumberBehavior() {
        do {
            var mock = Mock()
            XCTAssertEqual(mock.count, 5)

            mock.$count.increment(10)
            XCTAssertEqual(mock.count, 15)

            mock.$count.reset()
            XCTAssertEqual(mock.count, 5)

            mock.count = 10
            XCTAssertEqual(mock.count, 10)

            mock.$count.reset()
            XCTAssertEqual(mock.count, 5)

            mock.$count.increment(-10)
            XCTAssertEqual(mock.count, -5)

            mock.$count.reset()
            XCTAssertEqual(mock.count, 5)
        }

        do {
            var mock = Mock()
            XCTAssertEqual(mock.distance, 5.0)

            mock.$distance.increment(10.0)
            XCTAssertEqual(mock.distance, 15.0)

            mock.$distance.reset()
            XCTAssertEqual(mock.distance, 5.0)

            mock.distance = 10.0
            XCTAssertEqual(mock.distance, 10.0)

            mock.$distance.reset()
            XCTAssertEqual(mock.distance, 5.0)

            mock.$distance.increment(-10.0)
            XCTAssertEqual(mock.distance, -5.0)

            mock.$distance.reset()
            XCTAssertEqual(mock.distance, 5.0)
        }
    }
}
