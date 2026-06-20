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

    init(id: UUID = UUID(), text: String, isFromMe: Bool, date: Date = Date()) {
        self.id = id
        self.text = text
        self.isFromMe = isFromMe
        self.date = date
    }
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
