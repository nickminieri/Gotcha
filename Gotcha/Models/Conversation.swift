//
//  Conversation.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import Foundation

// MARK: - Message
struct Message: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var isFromMe: Bool
    var date: Date
    // Optional so older persisted messages still decode (nil == plain text).
    var kind: Kind?
    var offerAmount: Double?
    var offerStatus: OfferStatus?
    var meetupSpot: String?
    var meetupDate: Date?

    enum Kind: String, Codable { case text, offer, meetup, system }
    enum OfferStatus: String, Codable { case pending, accepted, declined }

    var resolvedKind: Kind { kind ?? .text }

    init(
        id: UUID = UUID(),
        text: String,
        isFromMe: Bool,
        date: Date = Date(),
        kind: Kind? = nil,
        offerAmount: Double? = nil,
        offerStatus: OfferStatus? = nil,
        meetupSpot: String? = nil,
        meetupDate: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.isFromMe = isFromMe
        self.date = date
        self.kind = kind
        self.offerAmount = offerAmount
        self.offerStatus = offerStatus
        self.meetupSpot = meetupSpot
        self.meetupDate = meetupDate
    }
}

// MARK: - Safe Meetup Spots (campus locations: public, well-lit, surveilled)
struct MeetupSpot: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let subtitle: String
    let symbol: String

    static let campusSpots: [MeetupSpot] = [
        MeetupSpot(name: "Student Union", subtitle: "Main lobby · busy & well-lit", symbol: "building.columns.fill"),
        MeetupSpot(name: "Main Library", subtitle: "Front entrance · cameras", symbol: "books.vertical.fill"),
        MeetupSpot(name: "Campus Police Station", subtitle: "Safest option · 24/7 staffed", symbol: "shield.lefthalf.filled"),
        MeetupSpot(name: "Recreation Center", subtitle: "Lobby · high foot traffic", symbol: "figure.run"),
        MeetupSpot(name: "Dining Hall Plaza", subtitle: "Open area · surveilled", symbol: "fork.knife")
    ]
}

// MARK: - Conversation
struct Conversation: Identifiable, Codable, Hashable {
    let id: UUID
    var sellerName: String
    var university: String
    var itemTitle: String
    var category: Item.Category
    var messages: [Message]
    var createdDate: Date
    var unreadCount: Int

    init(
        id: UUID = UUID(),
        sellerName: String,
        university: String,
        itemTitle: String,
        category: Item.Category,
        messages: [Message] = [],
        createdDate: Date = Date(),
        unreadCount: Int = 0
    ) {
        self.id = id
        self.sellerName = sellerName
        self.university = university
        self.itemTitle = itemTitle
        self.category = category
        self.messages = messages
        self.createdDate = createdDate
        self.unreadCount = unreadCount
    }

    var lastMessage: Message? { messages.last }
    var lastActivity: Date { messages.last?.date ?? createdDate }
}
