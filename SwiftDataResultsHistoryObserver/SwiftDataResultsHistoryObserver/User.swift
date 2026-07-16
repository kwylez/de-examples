import Foundation
import SwiftData

/// A simple persistent model used by both observer examples.
@Model
final class User {
    /// Identifier from the remote source, used to de-duplicate on sync.
    /// `nil` for users created only on-device.
    var remoteID: Int?
    var firstname: String
    var lastname: String
    var type: UserType
    /// When this user was added to the store. Used to sort lists newest-first.
    var createdAt: Date = Date.now

    init(remoteID: Int? = nil, firstname: String, lastname: String, type: UserType, createdAt: Date = .now) {
        self.remoteID = remoteID
        self.firstname = firstname
        self.lastname = lastname
        self.type = type
        self.createdAt = createdAt
    }

    var fullName: String {
        "\(firstname) \(lastname)"
    }
}

/// The role a `User` can have. Stored directly on the model as a `Codable` enum.
enum UserType: String, Codable, CaseIterable, Identifiable {
    case admin
    case moderator
    case regular

    var id: Self { self }

    var displayName: String {
        rawValue.capitalized
    }

    var symbolName: String {
        switch self {
        case .admin: "crown.fill"
        case .moderator: "shield.lefthalf.filled"
        case .regular: "person.fill"
        }
    }
}

// MARK: - Sample data

extension User {
    /// A small pool of names used when inserting example users.
    private static let firstNames = ["Ada", "Alan", "Grace", "Linus", "Margaret", "Dennis", "Katherine", "Edsger"]
    private static let lastNames = ["Lovelace", "Turing", "Hopper", "Torvalds", "Hamilton", "Ritchie", "Johnson", "Dijkstra"]

    /// Creates a randomly named user with a random role.
    ///
    /// Randomness is derived from `UUID` so the app does not depend on any
    /// particular seeding behavior.
    static func random() -> User {
        let firstIndex = UUID().uuidString.hashValue.magnitude % UInt(firstNames.count)
        let lastIndex = UUID().uuidString.hashValue.magnitude % UInt(lastNames.count)
        let type = UserType.allCases[Int(UUID().uuidString.hashValue.magnitude % UInt(UserType.allCases.count))]
        return User(
            firstname: firstNames[Int(firstIndex)],
            lastname: lastNames[Int(lastIndex)],
            type: type
        )
    }
}
