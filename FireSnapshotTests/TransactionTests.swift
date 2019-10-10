//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
    static let invalids = CollectionPath<Invalid>("invalids")

}

private struct Mock: SnapshotData {
    var count: Int = 0
}

private struct Invalid: SnapshotData {
    var name: String = ""
}

class TransactionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testTransaction() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 3
        let mock1 = Snapshot(data: .init(), path: .mocks)
        let mock2 = Snapshot(data: .init(), path: .mocks)
        let mock3 = Snapshot(data: .init(), path: .mocks)

        let batch = Firestore.firestore().batch()
        try! batch.create(mock1)
        try! batch.create(mock2)

        batch.commit { error in
            if let error = error {
                XCTFail("\(error)")
                exp.fulfill()
            }
            Firestore.firestore().runTransaction({ t, ep in
                do {
                    let m1 = try t.get(mock1.path)
                    let m2 = try t.get(mock2.path)
                    m1.count = 10
                    try t.update(m1)
                    t.delete(m2)
                    try t.create(mock3)
                } catch let error {
                    ep?.pointee = error as NSError
                }
                return nil
            }) { _, error in
                if let error = error {
                    XCTFail("\(error)")
                    exp.fulfill()
                }

                Snapshot.get(mock1.path) { result in
                    switch result {
                    case let .success(m):
                        XCTAssertEqual(m.count, 10)
                        exp.fulfill()
                    case let .failure(error):
                        XCTFail("\(error)")
                        exp.fulfill()
                    }
                }

                Snapshot.get(mock2.path) { result in
                    switch result {
                    case .success:
                        XCTFail()
                        exp.fulfill()
                    case let .failure(error):
                        XCTAssertEqual(error as? SnapshotError, SnapshotError.notExists)
                        exp.fulfill()
                    }
                }

                Snapshot.get(mock3.path) { result in
                    switch result {
                    case .success:
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

    func testTransactionFailed() {
        let exp = expectation(description: #function)
        Firestore.firestore().runTransaction({ t, ep in
            do {
                let m = Snapshot(data: .init(), path: .invalids)
                try t.create(m)
            } catch let error {
                ep?.pointee = error as NSError
            }
            return nil
        }) { _, error in
            if error != nil {
                exp.fulfill()
                return
            }
            XCTFail()
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10.0)
    }

}
