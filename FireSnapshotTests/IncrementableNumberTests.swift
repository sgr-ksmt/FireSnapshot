//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
}

private struct Mock: Codable {
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
        let batch = Firestore.firestore().batch()
        try! batch.create(mock1)
        try! batch.create(mock2)
        batch.commit { error in
            if let error = error {
                XCTFail("\(error)")
                return
            }

            Snapshot.get(mock1.path) { result in
                switch result {
                case let .success(mock):
                    XCTAssertEqual(mock.data.count, 5)
                    mock.data.$count.increment(10)
                    XCTAssertEqual(mock.data.count, 15)
                    XCTAssertEqual(mock.data.$count.incrementValue, 10)
                    mock.update { result in
                        switch result {
                        case .success:
                            Snapshot.get(mock1.path) { result in
                                XCTAssertEqual((try? result.get())?.data.count, 15)
                                exp.fulfill()
                            }
                        case let .failure(error):
                            XCTFail("\(error)")
                        }
                    }
                case let .failure(error):
                    XCTFail("\(error)")
                }
            }

            Snapshot.get(mock2.path) { result in
                switch result {
                case let .success(mock):
                    XCTAssertEqual(mock.data.distance, 5.0)
                    mock.data.$distance.increment(10.0)
                    XCTAssertEqual(mock.data.distance, 15.0)
                    XCTAssertEqual(mock.data.$distance.incrementValue, 10.0)
                    mock.update { result in
                        switch result {
                        case .success:
                            Snapshot.get(mock2.path) { result in
                                XCTAssertEqual((try? result.get())?.data.distance, 15.0)
                                exp.fulfill()
                            }
                        case let .failure(error):
                            XCTFail("\(error)")
                        }
                    }
                case let .failure(error):
                    XCTFail("\(error)")
                }
            }
        }

        wait(for: [exp], timeout: 10.0)
    }
}
