# FireSnapshot
![Swift](https://img.shields.io/badge/swift-5.1-orange.svg?style=for-the-badge)
![Firebase](https://img.shields.io/badge/firebase-6.9.0-orange.svg?style=for-the-badge)
![Platforms](https://img.shields.io/badge/Platforms-macOS-blue.svg?style=for-the-badge)
[![Git Version](https://img.shields.io/github/release/sgr-ksmt/FireSnapshot.svg?style=for-the-badge)](https://github.com/sgr-ksmt/FireSnapshot/releases)
[![license](https://img.shields.io/github/license/sgr-ksmt/FireSnapshot.svg?style=for-the-badge)](https://github.com/sgr-ksmt/FireSnapshot/blob/master/LICENSE)

Firebase Cloud Firestore Model Framework using Codable.


## Feature

- Support Codable.
- Support `FieldValue.increment` with `@propertyWrapper`
- Support KeyPath based query.

## Usage

🚧

## Installation

- CocoaPods

```ruby
pod 'FireSnapshot', '~> 0.2.0'
```

## Dependencies

- Firebase: v6.9.0 or higher.
- FirebaseFirestoreSwift: Fetch from master branch.
- Swift: v5.1 or higher.

## ToDo

- [ ] Supprt Batch.
- [ ] Support Transaction.
- [ ] Array Union/Remove.
- [ ] Write documentation more and more.
- [ ] Improve test coverage.

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
