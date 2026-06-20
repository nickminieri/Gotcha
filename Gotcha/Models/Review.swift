//
//  Review.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import Foundation

struct Review: Identifiable, Codable, Hashable {
    let id: UUID
    /// Display name of the seller being reviewed.
    var sellerName: String
    var reviewerName: String
    var rating: Int          // 1...5
    var text: String
    var date: Date

    init(
        id: UUID = UUID(),
        sellerName: String,
        reviewerName: String,
        rating: Int,
        text: String,
        date: Date = Date()
    ) {
        self.id = id
        self.sellerName = sellerName
        self.reviewerName = reviewerName
        self.rating = max(1, min(5, rating))
        self.text = text
        self.date = date
    }
}

/// Lightweight reference to a seller, used for navigation.
struct SellerRef: Hashable {
    let name: String
    let university: String
}
