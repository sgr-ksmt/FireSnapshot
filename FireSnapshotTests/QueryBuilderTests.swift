//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
}

private struct Mock: SnapshotData, HasTimestamps, FieldNameReferable {
    var count: Int = 0
    var name: String = ""
    var noRef: String = ""

    static var fieldNames: [PartialKeyPath<Mock> : String] {
        [
            \Self.self.name: "name",
            \Self.self.count: "count"
        ]
    }
}

class QueryBuilderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testQueryBuilderStack() {
        do {
            let qb = QueryBuilder<Mock>(CollectionPaths.mocks.collectionReference)
                .where(\.name, isEqualTo: "")
                .where(\.count, isEqualTo: 0)

            XCTAssertEqual(qb.call, 2)
            XCTAssertEqual(qb.stack, 2)
        }

        do {
            let qb = QueryBuilder<Mock>(CollectionPaths.mocks.collectionReference)
                .where(\.name, isEqualTo: "")
                .where(\.count, isEqualTo: 0)
                .where(\.noRef, isEqualTo: "")

            XCTAssertEqual(qb.call, 3)
            XCTAssertEqual(qb.stack, 2)
        }

        do {
            let queryBuilders: [(QueryBuilder<Mock>)->QueryBuilder<Mock>] = [
            { $0.where(\.name, isEqualTo: "") },
            { $0.where(\.name, isLessThan: "") },
            { $0.where(\.name, isLessThanOrEqualTo: "") },
            { $0.where(\.name, isGreaterThan: "") },
            { $0.where(\.name, isGreaterThanOrEqualTo: "") },
            { $0.order(\Mock.name, descending: false) },
            { $0.limit(to: 10) },
            { $0.where(.createTime, isEqualTo: Timestamp()) },
            { $0.where(.createTime, isLessThan: Timestamp()) },
            { $0.where(.createTime, isLessThanOrEqualTo: Timestamp()) },
            { $0.where(.createTime, isGreaterThan: Timestamp()) },
            { $0.where(.createTime, isGreaterThanOrEqualTo: Timestamp()) },
            { $0.where(.updateTime, isEqualTo: Timestamp()) },
            { $0.where(.updateTime, isLessThan: Timestamp()) },
            { $0.where(.updateTime, isLessThanOrEqualTo: Timestamp()) },
            { $0.where(.updateTime, isGreaterThan: Timestamp()) },
            { $0.where(.updateTime, isGreaterThanOrEqualTo: Timestamp()) },
            { $0.where(.createTime, isEqualTo: Date()) },
            { $0.where(.createTime, isLessThan: Date()) },
            { $0.where(.createTime, isLessThanOrEqualTo: Date()) },
            { $0.where(.createTime, isGreaterThan: Date()) },
            { $0.where(.createTime, isGreaterThanOrEqualTo: Date()) },
            { $0.where(.updateTime, isEqualTo: Date()) },
            { $0.where(.updateTime, isLessThan: Date()) },
            { $0.where(.updateTime, isLessThanOrEqualTo: Date()) },
            { $0.where(.updateTime, isGreaterThan: Date()) },
            { $0.where(.updateTime, isGreaterThanOrEqualTo: Date()) },
            { $0.order(.createTime, descending: false) },
            { $0.order(.updateTime, descending: false) },
            ]

            queryBuilders.forEach {
                let builder = $0(QueryBuilder<Mock>(CollectionPaths.mocks.collectionReference))
                XCTAssertEqual(builder.stack, 1)
                XCTAssertEqual(builder.call, 1)
            }
        }
    }

    func testWhereQuery() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 10
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.count = 10
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isEqualTo: 10).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isEqualTo: 9).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isLessThan: 11).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isLessThan: 10).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isLessThanOrEqualTo: 10).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isLessThanOrEqualTo: 9).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isGreaterThan: 9).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isGreaterThan: 10).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isGreaterThanOrEqualTo: 10).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).where(\.count, isGreaterThanOrEqualTo: 11).generate() }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }
            case let .failure(error):
                XCTFail("\(error)")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testOrderQuery() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 2
        let mock1 = Snapshot(data: .init(), path: .mocks)
        mock1.count = 10
        let mock2 = Snapshot(data: .init(), path: .mocks)
        mock2.count = 15

        let batch = Firestore.firestore().batch()
        try! batch.create(mock1)
        try! batch.create(mock2)

        batch.commit { error in
            if let error = error {
                XCTFail("\(error)")
                exp.fulfill()
            }

            Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).order(\Mock.count, descending: true).generate() }) { result in
                XCTAssertEqual((try? result.get())?.map { $0.count }, [15, 10])
                exp.fulfill()
            }

            Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).order(\Mock.count, descending: false).generate() }) { result in
                XCTAssertEqual((try? result.get())?.map { $0.count }, [10, 15])
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testLimitQuery() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 2
        let mock1 = Snapshot(data: .init(), path: .mocks)
        mock1.count = 10
        let mock2 = Snapshot(data: .init(), path: .mocks)
        mock2.count = 15

        let batch = Firestore.firestore().batch()
        try! batch.create(mock1)
        try! batch.create(mock2)

        batch.commit { error in
            if let error = error {
                XCTFail("\(error)")
                exp.fulfill()
            }

            Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).order(\Mock.count, descending: false).limit(to: 1).generate() }) { result in
                XCTAssertEqual((try? result.get())?.count, 1)
                XCTAssertEqual((try? result.get())?.first?.count, 10)
                exp.fulfill()
            }

            Snapshot.get(.mocks, queryBuilder: { QueryBuilder<Mock>($0).order(\Mock.count, descending: true).limit(to: 1).generate() }) { result in
                XCTAssertEqual((try? result.get())?.count, 1)
                XCTAssertEqual((try? result.get())?.first?.count, 15)
                exp.fulfill()
            }

        }
        wait(for: [exp], timeout: 10.0)
    }
}
