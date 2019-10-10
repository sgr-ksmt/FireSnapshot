//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import XCTest
@testable import FireSnapshot

private struct TestError: Error, Equatable {

}
class ResultTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test() {
        do {
            switch makeResult(Int(10), Optional<TestError>.none) {
            case let .success(num):
                XCTAssertEqual(num, 10)
            case .failure:
                XCTFail()
            }
        }

        do {
            switch makeResult(Optional<Int>.none, TestError()) {
            case .success:
                XCTFail()
            case let .failure(error):
                XCTAssertEqual(error as? TestError, TestError())
            }
        }

        do {
            switch makeResult(Int(10), TestError()) {
            case .success:
                XCTFail()
            case let .failure(error):
                if let error = error as? MakeResultError<Int, TestError> {
                    switch error {
                    case let .invalidCombination(value, error):
                        XCTAssertEqual(value, 10)
                        XCTAssertEqual(error, TestError())
                    }
                } else {
                    XCTFail()
                }
            }
        }

        do {
            switch makeResult(Optional<Int>.none, Optional<TestError>.none) {
            case .success:
                XCTFail()
            case let .failure(error):
                if let error = error as? MakeResultError<Int, TestError> {
                    switch error {
                    case let .invalidCombination(value, error):
                        XCTAssertEqual(value, nil)
                        XCTAssertEqual(error, nil)
                    }
                } else {
                    XCTFail()
                }
            }
        }
    }
}
