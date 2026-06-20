//
//  User.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var university: String
    var joinedDate: Date
    var rating: Double
    var reviewCount: Int
    var listedCount: Int
    /// Filename of the user's avatar photo in `ImageStore`, if any.
    var avatarFilename: String?

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        university: String = "",
        joinedDate: Date = Date(),
        rating: Double = 0.0,
        reviewCount: Int = 0,
        listedCount: Int = 0,
        avatarFilename: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.university = university
        self.joinedDate = joinedDate
        self.rating = rating
        self.reviewCount = reviewCount
        self.listedCount = listedCount
        self.avatarFilename = avatarFilename
    }

    static let preview = User(
        name: "Nick M.",
        email: "nick@nyu.edu",
        university: "NYU",
        rating: 4.8,
        reviewCount: 24,
        listedCount: 12
    )

    /// Builds a profile from a campus email, e.g. "jane.doe@mit.edu" ->
    /// name "Jane D.", university "MIT". Falls back to the preview profile when
    /// the address can't be parsed.
    static func fromCampusEmail(_ email: String) -> User {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let parts = trimmed.split(separator: "@", maxSplits: 1)
        guard parts.count == 2, !parts[0].isEmpty else { return .preview }

        // Local part -> "First L." display name.
        let localTokens = parts[0]
            .split(whereSeparator: { ".-_".contains($0) })
            .filter { !$0.isEmpty }
        let name: String
        if let first = localTokens.first {
            let firstName = first.prefix(1).uppercased() + first.dropFirst()
            if localTokens.count > 1, let lastInitial = localTokens.last?.prefix(1).uppercased() {
                name = "\(firstName) \(lastInitial)."
            } else {
                name = firstName
            }
        } else {
            name = "Student"
        }

        // Domain -> university label (known campuses mapped, else the school slug).
        let domain = String(parts[1])
        let knownCampuses: [String: String] = [
            "nyu.edu": "NYU", "mit.edu": "MIT", "bu.edu": "BU",
            "harvard.edu": "Harvard", "stanford.edu": "Stanford"
        ]
        let university = knownCampuses[domain]
            ?? domain.split(separator: ".").first.map { $0.uppercased() }
            ?? domain.uppercased()

        return User(
            name: name,
            email: trimmed,
            university: university,
            rating: 5.0,
            reviewCount: 0,
            listedCount: 0
        )
    }
}
