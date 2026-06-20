//
//  MessagingViewModel.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import Foundation
import UIKit
import Combine

class MessagingViewModel: ObservableObject {
    @Published var conversations: [Conversation] = [] {
        didSet { persistIfNeeded() }
    }
    /// The conversation currently on screen, so its replies don't count as unread.
    @Published var activeConversationID: UUID?

    private var persistenceEnabled = true
    private static let key = "gotcha.conversations.v1"

    init() {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-uiResetStore") {
            UserDefaults.standard.removeObject(forKey: Self.key)
        }
        if args.contains("-uiSeedMessages") {
            persistenceEnabled = false
            conversations = [
                Conversation(
                    sellerName: "Chris L.", university: "MIT",
                    itemTitle: "MacBook Pro 13\"", category: .electronics,
                    messages: [
                        Message(text: "Hi! Is the MacBook still available?", isFromMe: true,
                                date: Date(timeIntervalSinceNow: -3600)),
                        Message(text: "Yes it is! Barely used, comes with the box.", isFromMe: false,
                                date: Date(timeIntervalSinceNow: -3400)),
                        Message(text: "Offer", isFromMe: true, date: Date(timeIntervalSinceNow: -1800),
                                kind: .offer, offerAmount: 850, offerStatus: .accepted),
                        Message(text: "Chris L. accepted your offer of $850.00 🎉", isFromMe: false,
                                date: Date(timeIntervalSinceNow: -1700), kind: .system),
                        Message(text: "Meetup", isFromMe: true, date: Date(timeIntervalSinceNow: -1500),
                                kind: .meetup, meetupSpot: "Campus Police Station",
                                meetupDate: Date(timeIntervalSinceNow: 86400))
                    ]
                ),
                Conversation(
                    sellerName: "Riley B.", university: "Harvard",
                    itemTitle: "IKEA Desk Lamp", category: .furniture,
                    messages: [
                        Message(text: "Hey, can I pick this up tomorrow?", isFromMe: true,
                                date: Date(timeIntervalSinceNow: -7200)),
                        Message(text: "Sure, I'm around after 2pm 👍", isFromMe: false,
                                date: Date(timeIntervalSinceNow: -7000))
                    ],
                    unreadCount: 1
                )
            ]
        } else {
            load()
        }
        #else
        load()
        #endif
    }

    /// Conversations ordered by most recent activity.
    var sortedConversations: [Conversation] {
        conversations.sorted { $0.lastActivity > $1.lastActivity }
    }

    var totalUnread: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }

    func markRead(_ id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }),
              conversations[index].unreadCount != 0 else { return }
        conversations[index].unreadCount = 0
    }

    func deleteConversation(_ id: UUID) {
        conversations.removeAll { $0.id == id }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    /// Returns the existing conversation for an item/seller, or creates one
    /// seeded with a friendly opener from the seller. Returns its id.
    func openConversation(for item: Item) -> UUID {
        if let existing = conversations.first(where: {
            $0.itemTitle == item.title && $0.sellerName == item.sellerName
        }) {
            return existing.id
        }
        let opener = Message(
            text: "Hi! Thanks for your interest in the \(item.title). It's still available — let me know if you have questions!",
            isFromMe: false
        )
        let convo = Conversation(
            sellerName: item.sellerName,
            university: item.university,
            itemTitle: item.title,
            category: item.category,
            messages: [opener]
        )
        conversations.append(convo)
        return convo.id
    }

    /// Opens (or creates) the conversation for an item and returns the value,
    /// for pushing onto a navigation path.
    func openConversationValue(for item: Item) -> Conversation {
        let id = openConversation(for: item)
        return conversation(id: id) ?? Conversation(
            sellerName: item.sellerName, university: item.university,
            itemTitle: item.title, category: item.category
        )
    }

    func conversation(id: UUID) -> Conversation? {
        conversations.first(where: { $0.id == id })
    }

    func send(_ text: String, to id: UUID) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].messages.append(Message(text: trimmed, isFromMe: true))
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        scheduleAutoReply(for: id)
    }

    /// Sends a price offer; the seller auto-accepts shortly after (simulated).
    func sendOffer(_ amount: Double, to id: UUID) {
        guard amount > 0, let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        let offer = Message(
            text: "Offer",
            isFromMe: true,
            kind: .offer,
            offerAmount: amount,
            offerStatus: .pending
        )
        let offerID = offer.id
        conversations[index].messages.append(offer)
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        let sellerName = conversations[index].sellerName
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            guard let self,
                  let cIndex = self.conversations.firstIndex(where: { $0.id == id }),
                  let mIndex = self.conversations[cIndex].messages.firstIndex(where: { $0.id == offerID })
            else { return }
            self.conversations[cIndex].messages[mIndex].offerStatus = .accepted
            self.conversations[cIndex].messages.append(
                Message(text: "\(sellerName) accepted your offer of \(Self.priceString(amount)) 🎉",
                        isFromMe: false, kind: .system)
            )
            if self.activeConversationID != id { self.conversations[cIndex].unreadCount += 1 }
        }
    }

    /// Proposes a safe campus meetup; the seller confirms shortly after.
    func scheduleMeetup(spot: String, date: Date, to id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].messages.append(
            Message(text: "Meetup", isFromMe: true, kind: .meetup, meetupSpot: spot, meetupDate: date)
        )
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { [weak self] in
            guard let self, let cIndex = self.conversations.firstIndex(where: { $0.id == id }) else { return }
            self.conversations[cIndex].messages.append(
                Message(text: "Sounds good — see you at \(spot)! 👍", isFromMe: false)
            )
            if self.activeConversationID != id { self.conversations[cIndex].unreadCount += 1 }
        }
    }

    static func priceString(_ amount: Double) -> String {
        String(format: "$%.2f", amount)
    }

    /// A lightweight canned seller reply so threads feel alive in the demo.
    private func scheduleAutoReply(for id: UUID) {
        let replies = [
            "Sounds good! 👍",
            "Let me check and get back to you.",
            "Yeah, that works for me.",
            "Great — when are you free to meet on campus?",
            "It's still available!"
        ]
        let reply = replies.randomElement() ?? "Sounds good!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { [weak self] in
            guard let self,
                  let index = self.conversations.firstIndex(where: { $0.id == id }) else { return }
            self.conversations[index].messages.append(Message(text: reply, isFromMe: false))
            // Count it as unread only if the user isn't looking at this thread.
            if self.activeConversationID != id {
                self.conversations[index].unreadCount += 1
            }
        }
    }

    // MARK: - Persistence
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let saved = try? JSONDecoder().decode([Conversation].self, from: data) else { return }
        conversations = saved
    }

    private func persistIfNeeded() {
        guard persistenceEnabled else { return }
        guard let data = try? JSONEncoder().encode(conversations) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }
}
