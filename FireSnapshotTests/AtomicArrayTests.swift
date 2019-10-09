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
    @AtomicArray var languages: [String] = ["ja"]
}

class AtomicArrayTests: XCTestCase {

    override func setUp() {
        super.setUp()
         FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testUnionUpdate() {
        let exp = XCTestExpectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    switch result {
                    case let .success(m):
                        XCTAssertEqual(m.languages, ["ja"])
                        m.$languages.union("en")
                        XCTAssertEqual(m.languages, ["ja", "en"])
                        m.update { result in
                            switch result {
                            case .success:
                                Snapshot.get(mock.path) { result in
                                    XCTAssertEqual((try? result.get())?.languages, ["ja", "en"])
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
        wait(for: [exp], timeout: 30.0)
    }

    func testRemoveUpdate() {
        let exp = XCTestExpectation(description: #function)
        let mock = Snapshot(data: .init(languages: ["ja", "en", "zh"]), path: .mocks)
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    switch result {
                    case let .success(m):
                        XCTAssertEqual(m.languages, ["ja", "en", "zh"])
                        m.$languages.remove("en")
                        XCTAssertEqual(m.languages, ["ja", "zh"])
                        m.update { result in
                            switch result {
                            case .success:
                                Snapshot.get(mock.path) { result in
                                    XCTAssertEqual((try? result.get())?.languages, ["ja", "zh"])
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
        wait(for: [exp], timeout: 30.0)
    }

    func testAtomicArrayBehavior() {
        do {
            var mock = Mock()
            XCTAssertEqual(mock.languages, ["ja"])

            mock.$languages.union("en")
            XCTAssertEqual(mock.languages, ["ja", "en"])

            mock.$languages.reset()
            XCTAssertEqual(mock.languages, ["ja"])

            mock.$languages.union("en")
            mock.$languages.union("zh")
            XCTAssertEqual(mock.languages, ["ja", "zh"])

            mock.$languages.reset()
            XCTAssertEqual(mock.languages, ["ja"])

            mock.$languages.union(["en", "zh"])
            XCTAssertEqual(mock.languages, ["ja", "en", "zh"])
        }


        do {
            var mock = Mock(languages: ["ja", "en"])
            XCTAssertEqual(mock.languages, ["ja", "en"])

            mock.$languages.remove("en")
            XCTAssertEqual(mock.languages, ["ja"])

            mock.$languages.reset()
            XCTAssertEqual(mock.languages, ["ja", "en"])

            mock.$languages.remove("en")
            mock.$languages.remove("ja")
            XCTAssertEqual(mock.languages, ["en"])

            mock.$languages.reset()
            XCTAssertEqual(mock.languages, ["ja", "en"])

            mock.$languages.remove(["en", "ja"])
            XCTAssertEqual(mock.languages, [])

            mock.$languages.reset()
            XCTAssertEqual(mock.languages, ["ja", "en"])

            mock.$languages.remove("zh")
            XCTAssertEqual(mock.languages, ["ja", "en"])
        }
    }
}
