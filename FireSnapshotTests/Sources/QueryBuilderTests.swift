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
    var countries: [String] = []

    static var fieldNames: [PartialKeyPath<Mock> : String] {
        [
            \Self.self.name: "name",
            \Self.self.count: "count",
            \Self.self.countries: "countries"
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
                .where(\.name == "")
                .where(\.count == 0)

            XCTAssertEqual(qb.call, 2)
            XCTAssertEqual(qb.stack, 2)
        }

        do {
            let qb = QueryBuilder<Mock>(CollectionPaths.mocks.collectionReference)
                .where(\.name == "")
                .where(\.count == 0)
                .where(\.noRef == "")

            XCTAssertEqual(qb.call, 3)
            XCTAssertEqual(qb.stack, 2)
        }

        do {
            let queryBuilders: [(QueryBuilder<Mock>)->QueryBuilder<Mock>] = [
            { $0.where(\.name == "") },
            { $0.where(\.name < "") },
            { $0.where(\.name <= "") },
            { $0.where(\.name > "") },
            { $0.where(\.name >= "") },
            { $0.where(\.countries ~= "") },
            { $0.where(\.name || ["x", "y"])},
            { $0.where(\.countries ~|| ["x", "y"])},
            { $0.order(by: \Mock.name, descending: false) },
            { $0.limit(to: 10) },
            { $0.where(.createTime == Timestamp()) },
            { $0.where(.createTime < Timestamp()) },
            { $0.where(.createTime <= Timestamp()) },
            { $0.where(.createTime > Timestamp()) },
            { $0.where(.createTime >= Timestamp()) },
            { $0.where(.updateTime == Timestamp()) },
            { $0.where(.updateTime < Timestamp()) },
            { $0.where(.updateTime <= Timestamp()) },
            { $0.where(.updateTime > Timestamp()) },
            { $0.where(.updateTime >= Timestamp()) },
            { $0.where(.createTime == Date()) },
            { $0.where(.createTime < Date()) },
            { $0.where(.createTime <= Date()) },
            { $0.where(.createTime > Date()) },
            { $0.where(.createTime >= Date()) },
            { $0.where(.updateTime == Date()) },
            { $0.where(.updateTime < Date()) },
            { $0.where(.updateTime <= Date()) },
            { $0.where(.updateTime > Date()) },
            { $0.where(.updateTime >= Date()) },
            { $0.order(by: .createTime, descending: false) },
            { $0.order(by: .updateTime, descending: false) },
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
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count == 10) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count == 9) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count < 11) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count < 10) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count <= 10) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count <= 9) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count > 9) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count > 10) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 0)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count >= 10) }) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }

                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.count >= 11) }) { result in
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

    func testArrayContains() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 2
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.countries = ["jp", "us", "uk"]
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.countries ~= "jp")}) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.countries ~= "de")}) { result in
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

    func testArrayContainsAny() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 3
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.countries = ["jp"]
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.countries ~|| ["jp"])}) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.countries ~|| ["jp", "us"])}) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.countries ~|| ["us", "de"])}) { result in
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

    func testIn() {
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 3
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.name = "xxx"
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.name || ["xxx"])}) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.name || ["xxx", "yyy"])}) { result in
                    XCTAssertEqual((try? result.get())?.count, 1)
                    exp.fulfill()
                }
                Snapshot.get(.mocks, queryBuilderBlock: { $0.where(\.name || ["yyy", "zzz"])}) { result in
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

        let batch = Batch()
            .create(mock1)
            .create(mock2)

        batch.commit { error in
            if let error = error {
                XCTFail("\(error)")
                exp.fulfill()
            }

            Snapshot.get(.mocks, queryBuilderBlock: { $0.order(by: \Mock.count, descending: true) }) { result in
                XCTAssertEqual((try? result.get())?.map { $0.count }, [15, 10])
                exp.fulfill()
            }

            Snapshot.get(.mocks, queryBuilderBlock: { $0.order(by: \Mock.count, descending: false) }) { result in
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

        let batch = Batch()
            .create(mock1)
            .create(mock2)

        batch.commit { error in
            if let error = error {
                XCTFail("\(error)")
                exp.fulfill()
            }

            Snapshot.get(.mocks, queryBuilderBlock: { $0.order(by: \Mock.count, descending: false).limit(to: 1) }) { result in
                XCTAssertEqual((try? result.get())?.count, 1)
                XCTAssertEqual((try? result.get())?.first?.count, 10)
                exp.fulfill()
            }

            Snapshot.get(.mocks, queryBuilderBlock: { $0.order(by: \Mock.count, descending: true).limit(to: 1) }) { result in
                XCTAssertEqual((try? result.get())?.count, 1)
                XCTAssertEqual((try? result.get())?.first?.count, 15)
                exp.fulfill()
            }

        }
        wait(for: [exp], timeout: 10.0)
    }

    func testQueryOperator() {

    }
}
