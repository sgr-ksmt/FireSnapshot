//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

public extension Snapshot {
    typealias WriteResultBlock = (Result<Void, Error>) -> Void

    func create(encoder: Firestore.Encoder = .init(),
             merge: Bool = false,
             completion: @escaping WriteResultBlock = { _ in }) {
        do {
            var fields = try encoder.encode(data)
            if data is HasTimestamps {
                fields[HasTimestampsKeys.createTime] = FieldValue.serverTimestamp()
                fields[HasTimestampsKeys.updateTime] = FieldValue.serverTimestamp()
            }
            reference.setData(fields, merge: merge, completion: Self.writeCompletion(completion))
        } catch {
            completion(.failure(error))
        }
    }

    func update(encoder: Firestore.Encoder = .init(),
                completion: @escaping WriteResultBlock = { _ in }) {
        do {
            var fields = try encoder.encode(data)
            if data is HasTimestamps {
                fields[HasTimestampsKeys.updateTime] = FieldValue.serverTimestamp()
            }
            reference.updateData(fields, completion: Self.writeCompletion(completion))
        } catch {
            completion(.failure(error))
        }
    }

    func remove(completion: @escaping WriteResultBlock = { _ in }) {
        reference.delete(completion: Self.writeCompletion(completion))
    }

    private static func writeCompletion(_ completion: @escaping WriteResultBlock) -> (Error?) -> Void {
        return { error in completion(error.map { .failure($0) } ?? .success(())) }
    }
}
