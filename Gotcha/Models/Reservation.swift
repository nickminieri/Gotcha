//
//  Reservation.swift
//  Gotcha
//
//  A buyer's reserved item: a snapshot of the listing plus the agreed safe
//  meetup, so it can be tracked from the Profile tab independent of the listing.
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct Reservation: Identifiable, Codable, Hashable {
    enum Status: String, Codable {
        case active
        case completed
        case cancelled

        var label: String {
            switch self {
            case .active:    return "Reserved"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            }
        }

        var tint: Color {
            switch self {
            case .active:    return Color(red: 0.45, green: 0.70, blue: 1.00)
            case .completed: return Color(red: 0.40, green: 0.80, blue: 0.55)
            case .cancelled: return Color(red: 0.95, green: 0.32, blue: 0.40)
            }
        }
    }

    var id = UUID()
    // Snapshot of the listing at reservation time.
    var itemID: UUID
    var title: String
    var price: Double
    var imageFilename: String?
    var category: Item.Category
    var sellerName: String
    var university: String
    // Agreed meetup.
    var meetupSpot: String
    var meetupDate: Date
    var confirmationNumber: String
    var createdDate = Date()
    var status: Status = .active
}
