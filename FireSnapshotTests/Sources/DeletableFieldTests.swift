//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
import FirebaseFirestore

@testable import FireSnapshot

private extension CollectionPaths {
    static let mocks = CollectionPath<Mock>("mocks")
    static let mocks2 = CollectionPath<Mock2>("mocks")
    static let mocks3 = CollectionPath<Mock3>("mocks")
}

private struct Mock: SnapshotData {
    var bio: DeletableField<String>? = .init(value: "initial")
}

private struct Mock2: SnapshotData {
    var names: DeletableField<[String]>? = .init(value: [])
}

private struct Mock3: SnapshotData {
    struct Size: Codable {
        var width: Double = 0.0
        var height: Double = 0.0
    }
    var size: DeletableField<Size>? = .init(value: .init())
}


class DeletableFieldTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    func testDelete() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks)
        mock.bio?.value = "I'm a software engineer"
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    switch result {
                    case let .success(m):
                        XCTAssertNotNil(m.bio)
                        XCTAssertEqual(m.bio?.value, "I'm a software engineer")
                        m.bio?.delete()
                        m.update { result in
                            switch result {
                            case .success:
                                Snapshot.get(m.path) { result in
                                    XCTAssertNotNil((try? result.get()))
                                    XCTAssertNil((try? result.get())?.bio)
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

    func testDeleteList() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks2)
        mock.names?.value = ["Mike", "John"]
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    switch result {
                    case let .success(m):
                        XCTAssertNotNil(m.names)
                        XCTAssertEqual(m.names?.value, ["Mike", "John"])
                        m.names?.delete()
                        m.update { result in
                            switch result {
                            case .success:
                                Snapshot.get(m.path) { result in
                                    XCTAssertNotNil((try? result.get()))
                                    XCTAssertNil((try? result.get())?.names)
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

    func testDeleteMap() {
        let exp = expectation(description: #function)
        let mock = Snapshot(data: .init(), path: .mocks3)
        mock.size?.value = .init(width: 100, height: 100)
        mock.create { result in
            switch result {
            case .success:
                Snapshot.get(mock.path) { result in
                    switch result {
                    case let .success(m):
                        XCTAssertNotNil(m.size)
                        XCTAssertEqual(m.size?.value?.width, 100)
                        XCTAssertEqual(m.size?.value?.height, 100)
                        m.size?.delete()
                        m.update { result in
                            switch result {
                            case .success:
                                Snapshot.get(m.path) { result in
                                    XCTAssertNotNil((try? result.get()))
                                    XCTAssertNil((try? result.get())?.size)
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

    func testDeletableFieldBehavior() {
        var mock = Mock()
        XCTAssertNotNil(mock.bio)
        mock.bio!.value = "I'm a software engineer"
        XCTAssertEqual(mock.bio!.value, "I'm a software engineer")
        mock.bio!.delete()
        XCTAssertEqual(mock.bio!.value, nil)

        mock.bio!.reset()
        XCTAssertEqual(mock.bio!.value, "initial")

        mock.bio = nil
        XCTAssertNil(mock.bio)
        mock.bio = .init(value: "I'm a hardware engineer")
        XCTAssertNotNil(mock.bio)
        XCTAssertEqual(mock.bio!.value, "I'm a hardware engineer")
    }
}
