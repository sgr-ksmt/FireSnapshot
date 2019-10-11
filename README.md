# FireSnapshot
![Swift](https://img.shields.io/badge/swift-5.1-orange.svg?style=for-the-badge)
![Firebase](https://img.shields.io/badge/firebase-6.9.0-orange.svg?style=for-the-badge)
[![Git Version](https://img.shields.io/github/release/sgr-ksmt/FireSnapshot.svg?style=for-the-badge)](https://github.com/sgr-ksmt/FireSnapshot/releases)
![Bitrise](https://img.shields.io/bitrise/088b3cb378bed01b/master?style=for-the-badge&token=W33-pqQu735MA5qn3GGn5w)
[![license](https://img.shields.io/github/license/sgr-ksmt/FireSnapshot.svg?style=for-the-badge)](https://github.com/sgr-ksmt/FireSnapshot/blob/master/LICENSE)

Firebase Cloud Firestore Model Framework using Codable.


## Feature

- Support Codable.
- Support `ArrayUnion/ArrayRemove` with `@propertyWrapper`.
- Support `FieldValue.increment` with `@propertyWrapper`
- Support `FieldValue.delete()`.
- Support KeyPath based query.

### Use Swift features(version: 5.1)

- `@propertyWrapper`: [SE-0258](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md)
- Key Path Member Lookup: [SE-0252](https://github.com/apple/swift-evolution/blob/master/proposals/0252-keypath-dynamic-member-lookup.md)

## Usage

🚧

```swift
// Define model and conform to protocol `SnapshotData`.
struct User: SnapshotData {
    var name: String
}

// Define collection/document path
extension CollectionPaths {
    static let users = CollectionPath<User>("users")
}

extension DocumentPaths {
    static func user(userID: String) -> DocumentPath<User> {
        CollectionPaths.users.document(userID)
    }
}

// Create user
let user = Snapshot(data: .init(name: "Mike"), path: .users)
user.create()

// Update user
user.name = "John"
user.update()

// Get user
Snapshot.get(.user(userID: "xxxx")) { result in
    switch result {
    case let .success(user):
        print(user.name)
    case let .failure(error):
        print(error)
    }
}
```

## Installation

- CocoaPods

```ruby
pod 'FireSnapshot', '~> 0.6.0'
```

## Dependencies

- Firebase: v6.9.0 or higher.
- FirebaseFirestoreSwift: Fetch from master branch.
- Swift: v5.1 or higher.

## ToDo

- [ ] Write documentation more and more.

## Road to 1.0

- Until 1.0 is reached, minor versions will be breaking 🙇‍.


## Development

### Setup

```sh
$ git clone ...
$ cd path/to/FireSnapshot
$ make
$ open FireSnapshot.xcworkspace
```

### Unit Test

Start `Firestore Emulator` before running Unit Test.

```sh
$ npm install -g firebase-tools
$ firebase setup:emulators:firestore
$ cd ./firebase/
$ firebase emulators:start --only firestore
# Open Xcode and run Unit Test after running emulator.
```

or, run `./scripts/test.sh`.

## Communication

- If you found a bug, open an issue.
- If you have a feature request, open an issue.
- If you want to contribute, submit a pull request.:muscle:

## Credit

FireSnapshot was inspired by followings:

- [starhoshi/tart](https://github.com/starhoshi/tart)
- [alickbass/CodableFirebase](https://github.com/alickbass/CodableFirebase)

## License

**FireSnapshot** is under MIT license. See the [LICENSE](LICENSE) file for more info.
