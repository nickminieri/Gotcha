//
//  User.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import Foundation

struct User: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var university: String
    var joinedDate: Date
    var rating: Double
    var reviewCount: Int
    var listedCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        university: String = "",
        joinedDate: Date = Date(),
        rating: Double = 0.0,
        reviewCount: Int = 0,
        listedCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.university = university
        self.joinedDate = joinedDate
        self.rating = rating
        self.reviewCount = reviewCount
        self.listedCount = listedCount
    }

    static let preview = User(
        name: "Nick M.",
        email: "nick@nyu.edu",
        university: "NYU",
        rating: 4.8,
        reviewCount: 24,
        listedCount: 12
    )
}
