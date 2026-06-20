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
                        Message(text: "Could you do $850?", isFromMe: true,
                                date: Date(timeIntervalSinceNow: -1800))
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
                    ]
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
