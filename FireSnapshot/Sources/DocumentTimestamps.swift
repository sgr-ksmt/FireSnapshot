//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation

public protocol HasTimestamps {}

public enum SnapshotTimestampKey: String  {
    case createTime
    case updateTime
}
