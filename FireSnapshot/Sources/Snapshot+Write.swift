//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import FirebaseFirestore
import Foundation

public extension Snapshot {
    typealias WriteResultBlock = (Result<Void, Error>) -> Void

    func create(merge: Bool = false,
                completion: @escaping WriteResultBlock = { _ in }) {
        do {
            reference.setData(try extractWriteFieldsForCreate(), merge: merge, completion: Self.writeCompletion(completion))
        } catch {
            completion(.failure(error))
        }
    }

    func merge(completion: @escaping WriteResultBlock = { _ in }) {
        create(merge: true, completion: completion)
    }

    func update(completion: @escaping WriteResultBlock = { _ in }) {
        do {
            reference.updateData(try extractWriteFieldsForUpdate(), completion: Self.writeCompletion(completion))
        } catch {
            completion(.failure(error))
        }
    }

    func delete(completion: @escaping WriteResultBlock = { _ in }) {
        reference.delete(completion: Self.writeCompletion(completion))
    }

    private static func writeCompletion(_ completion: @escaping WriteResultBlock) -> (Error?) -> Void {
        return { error in completion(error.map { .failure($0) } ?? .success(())) }
    }
}
