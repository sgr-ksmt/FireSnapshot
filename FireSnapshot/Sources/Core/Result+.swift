//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation

public enum MakeResultError<T, E: Error>: Error {
    case invalidCombination(value: T?, error: E?)
}

func makeResult<T, E: Error>(_ value: T?, _ error: E?) -> Result<T, Error> {
    switch (value, error) {
    case let (.some(value), .none):
        return .success(value)
    case let (.none, .some(error)):
        return .failure(error)
    default:
        return .failure(MakeResultError.invalidCombination(value: value, error: error))
    }
}
