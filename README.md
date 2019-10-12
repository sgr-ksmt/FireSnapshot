<p align='center'>

<img src='https://raw.githubusercontent.com/sgr-ksmt/FireSnapshot/master/assets/logo.png' width='600px' />

</p>

<div align='center'>

[![Release](https://img.shields.io/github/release/sgr-ksmt/FireSnapshot.svg?style=for-the-badge)](https://github.com/sgr-ksmt/FireSnapshot/releases)
![Swift](https://img.shields.io/badge/swift-5.1-orange.svg?style=for-the-badge)
![Firebase](https://img.shields.io/badge/firebase-6.9.0-orange.svg?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg?style=for-the-badge)

![Bitrise](https://img.shields.io/bitrise/088b3cb378bed01b/master?style=for-the-badge&token=W33-pqQu735MA5qn3GGn5w)
[![license](https://img.shields.io/github/license/sgr-ksmt/FireSnapshot.svg?style=for-the-badge)](https://github.com/sgr-ksmt/FireSnapshot/blob/master/LICENSE)

**Firebase Cloud Firestore Model Framework using Codable.**  

Developed by [@sgr-ksmt](https://github.com/sgr-ksmt) [![Twitter Follow](https://img.shields.io/twitter/follow/_sgr_ksmt?label=Follow&style=social)](https://twitter.com/_sgr_ksmt)
</div>

<hr />

## Feature

- 🙌 Support Codable (Use [`FirebaseFirestoreSwift`](https://github.com/firebase/firebase-ios-sdk/tree/master/Firestore/Swift) inside).
- 🙌 Provide easy-to-use methods for CRUD, Batch, Transaction.
- 🙌 Support `array-union/array-remove`.
- 🙌 Support `FieldValue.increment`.
- 🙌 Support `FieldValue.delete()`.
- 🙌 Support KeyPath based query.

### Use Swift features(version: 5.1)

- 💪 **`@propertyWrapper`**: [SE-0258](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md)
- 💪 **Key Path Member Lookup**: [SE-0252](https://github.com/apple/swift-evolution/blob/master/proposals/0252-keypath-dynamic-member-lookup.md)

<hr />

## Usage

### Basic Usage

The type of `Document` must be conformed to the `SnapshotData` protocol.  
`SnapshotData` protocol inherits `Codable`.  For example: 

```swift
struct Product: SnapshotData {
    var name: String = ""
    var desc: String?
    var price: Int = 0
    var attributes: [String: String] = [:]
}
```

It is convenient to define `DocumentPath<T>` and `CollectionPath<T>`.  
Define path for extension of `DocumentPaths` or `CollectionPaths`.


```swift
extension CollectionPaths {
    static let products = CollectionPath<Product>("products")
}

extension DocumentPaths {
    static func product(_ productID: String) -> DocumentPath<Product> {
        CollectionPaths.products.document(productID)
    }
}
```

Create `Snapshot` with model that comformed to `SnapshotData` and path.

```swift
let product = Snapshot<Product>(data: Product(), path: CollectionPath.products)
```

In short 👇

```swift
let product = Snapshot(data: .init(), path: .products)
```

You can save it by calling `create(completion:)`

```swift
product.create { error in
    if let error = error {
        print("error", error)
        return
    }
    print("created!")
}
```

`FireSnapshot` also provides read(`get document(s)/listen document(s)`), write(`update/delete`), write with batch and transaction

```swift
// Update document
product.update { error in
    if let error = error {
        print("error", error)
        return
    }
    print("updated!")
}

// Delete document
product.delete { error in
    if let error = error {
        print("error", error)
        return
    }
    print("deleted!")
}

// Get document
Snapshot.get(.product("some_product_id")) { result in
    switch result {
    case let .success(product):
        print(product.name)
    case let .failure(error):
        print(error)
    }
}

// Listen document
let listener = Snapshot.listen(.product("some_product_id")) { result in
    switch result {
    case let .success(product):
        print("listened new product", product.name)
    case let .failure(error):
        print(error)
    }
}

// Get documents
Snapshot.get(.products) { result in
    switch result {
    case let .success(products):
        print(products.count)
    case let .failure(error):
        print(error)
    }
}

// Listen documents
let listener = Snapshot.listen(.products) { result in
    switch result {
    case let .success(products):
        print("listened new products", products.count)
    case let .failure(error):
        print(error)
    }
}
```

If you can read/write timestamp such as `createTime` and `updateTime`, model must be conform to `HasTimestamps` protocol.

```swift
struct Product: SnapshotData, HasTimestamps {
    var name: String = ""
    var desc: String?
    var price: Int = 0
    var attributes: [String: String] = [:]
}

let product = Snapshot(data: .init(), path: .products)
// `createTime` and `updateTime` will be written to field with other properties.
product.create()

Snapshot.get(product.path) { result in
    guard let p = try? result.get() else {
        return
    }

    // optional timestamp value.
    print(p.createTime)
    print(p.updateTime)

    // `updateTime` will be updated with other properties.
    p.update()
}
```

<hr />

### Advanced Usage

#### `@IncrementableInt` / `@IncrementableDouble`

If you want to use `FieldValue.increment` on model, use `@IncrementableInt(Double)`.  

- The type of `@IncrementableInt` property is `Int64`.  
- The type of `@IncrementableDouble` property is `Double`.  

```swift
extension CollectionPaths {
    static let products = CollectionPath<Model>("models")
}

struct Model: SnapshotData {
    @IncrementableInt var count = 10
    @IncrementableDouble var distance = 10.0
}

Snapshot.get(.model(modelID)) { result in
    guard let model = try? result.get() else {
        return
    }
    // Refer a number
    print(model.count) // print `10`.
    print(model.distance) // print `10.0`.

    // Increment (use `$` prefix)
    model.$count.increment(1)
    print(model.count) // print `11`.
    model.update()

    model.$distance.increment(1.0)
    print(model.distance) // print `11.0`.
    model.update()

    // Decrement
    model.$count.increment(-1)
    print(model.count) // print `9`.
    model.update()

    model.$distance.increment(-1.0)
    print(model.distance) // print `9.0`.
    model.update()

    // if you want to reset property, use `reset` method.
    model.$count.reset()
}
```

#### `@AtomicArray`

If you want to use `FieldValue.arrayUnion` or `FieldValue.arrayRemove`, use `@AtomicArray`.  

The type of `@AtomicArray`'s element must be conformed to `Codable` protocol.

```swift
extension CollectionPaths {
    static let products = CollectionPath<Model>("models")
}

struct Model: SnapshotData {
    @AtomicArray var languages: [String] = ["en", "ja"]
}

Snapshot.get(.model(modelID)) { result in
    guard let model = try? result.get() else {
        return
    }

    // Refer an array
    print(model.languages) // print `["en", "ja"]`.

    // Union element(s)
    model.$languages.union("zh")
    print(model.count) // print `["en", "ja", "zh"]`.
    model.update()

    // Remove element(s)
    model.$languages.remove("en")
    print(model.count) // print `["ja"]`.
    model.update()

    // if you want to reset property, use `reset` method.
    model.$languages.reset()
}
```

#### `@DeletableField`

IF you want to use `FieldValue.delete`, use `@DeletableField`.

```swift
extension CollectionPaths {
    static let products = CollectionPath<Model>("models")
}

struct Model: SnapshotData {
    var bio: DeletableField<String>? = .init(value: "I'm a software engineer.")
}

Snapshot.get(.model(modelID)) { result in
    guard let model = try? result.get() else {
        return
    }

    print(model.bio?.value) // print `Optional("I'm a software engineer.")`

    // Delete property
    model.bio.delete()
    model.update()
}

// After updated
Snapshot.get(.model(modelID)) { result in
    guard let model = try? result.get() else {
        return
    }

    print(model.bio) // nil
    print(model.bio?.value) // nil
}
```

**NOTE:** 
Normally, when property is set to nil, `{key: null}` will be written to document,  
but when using `FieldValue.delete`, field of `key` will be deleted from document.

#### KeyPath-based query

You can use KeyPath-based query generator called `QueryBuilder` if the model conform to `FieldNameReferable` protocol.

```swift
extension CollectionPaths {
    static let products = CollectionPath<Product>("products")
}

struct Product: SnapshotData, HasTimestamps {
    var name: String = ""
    var desc: String?
    var price: Int = 0
    var deleted: Bool = false
    var attributes: [String: String] = [:]
}

extension Product: FieldNameReferable {
    static var fieldNames: [PartialKeyPath<Mock> : String] {
        return [
            \Self.self.name: "name",
            \Self.self.desc: "desc",
            \Self.self.price: "price",
            \Self.self.deleted: "deleted",
        ]
    }
}

Snapshot.get(.products, queryBuilder: { builder in
    builder
        .where(\.price, isGreaterThan: 5000)
        .where(\.deleted, isEqualTo: false)
        .order(by: \.updateTime, descending: true)
}) { result in
    ...
}
```

<hr />

## Installation

- CocoaPods

```ruby
pod 'FireSnapshot', '~> 0.6.0'
```

<hr />

## Dependencies

- Firebase: `v6.9.0` or higher.
- FirebaseFirestoreSwift: Fetch from master branch.
- Swift: `5.1` or higher.

<hr />

## Road to 1.0

- Until 1.0 is reached, minor versions will be breaking 🙇‍.


<hr />

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

<hr />

## Communication

- If you found a bug, open an issue.
- If you have a feature request, open an issue.
- If you want to contribute, submit a pull request.:muscle:

<hr />

## Credit

FireSnapshot was inspired by followings:

- [starhoshi/tart](https://github.com/starhoshi/tart)
- [alickbass/CodableFirebase](https://github.com/alickbass/CodableFirebase)

<hr />

## License

**FireSnapshot** is under MIT license. See the [LICENSE](LICENSE) file for more info.
