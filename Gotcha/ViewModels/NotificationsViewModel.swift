//
//  NotificationsViewModel.swift
//  Gotcha
//
//  Owns the in-app activity feed: persistence, unread tracking, and the entry
//  point other view models call to record activity.
//
//  Created by Nicholas Minieri on 4/28/24.
//

import Foundation
import UIKit
import Combine

class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = [] {
        didSet { persistIfNeeded() }
    }

    private var persistenceEnabled = true
    private static let key = "gotcha.notifications.v1"

    init() {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-uiResetStore") {
            UserDefaults.standard.removeObject(forKey: Self.key)
        }
        if args.contains("-uiSeedNotifications") {
            persistenceEnabled = false
            notifications = Self.sample
        } else {
            load()
        }
        #else
        load()
        #endif
    }

    /// Activity ordered newest first.
    var sorted: [AppNotification] {
        notifications.sorted { $0.date > $1.date }
    }

    var unreadCount: Int {
        notifications.lazy.filter { !$0.isRead }.count
    }

    var hasUnread: Bool { unreadCount > 0 }

    /// Records a new activity item at the top of the feed.
    func add(_ note: AppNotification) {
        notifications.insert(note, at: 0)
    }

    /// Convenience for the common call site.
    func add(kind: AppNotification.Kind, title: String, body: String, actorName: String? = nil) {
        add(AppNotification(kind: kind, title: title, body: body, actorName: actorName))
    }

    func markRead(_ id: UUID) {
        guard let index = notifications.firstIndex(where: { $0.id == id }),
              !notifications[index].isRead else { return }
        notifications[index].isRead = true
    }

    func markAllRead() {
        guard hasUnread else { return }
        for index in notifications.indices { notifications[index].isRead = true }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func delete(_ id: UUID) {
        notifications.removeAll { $0.id == id }
    }

    func clearAll() {
        guard !notifications.isEmpty else { return }
        notifications.removeAll()
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    // MARK: - Persistence
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let saved = try? JSONDecoder().decode([AppNotification].self, from: data) else { return }
        notifications = saved
    }

    private func persistIfNeeded() {
        guard persistenceEnabled else { return }
        guard let data = try? JSONEncoder().encode(notifications) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    #if DEBUG
    static let sample: [AppNotification] = [
        AppNotification(kind: .offer, title: "Offer accepted",
                        body: "Chris L. accepted your $850.00 offer on “MacBook Pro 13\"”.",
                        date: Date(timeIntervalSinceNow: -1700), isRead: false, actorName: "Chris L."),
        AppNotification(kind: .meetup, title: "Meetup confirmed",
                        body: "Tomorrow at the Campus Police Station with Chris L.",
                        date: Date(timeIntervalSinceNow: -1500), isRead: false, actorName: "Chris L."),
        AppNotification(kind: .message, title: "New message",
                        body: "Riley B.: “Sure, I'm around after 2pm 👍”",
                        date: Date(timeIntervalSinceNow: -7000), isRead: false, actorName: "Riley B."),
        AppNotification(kind: .review, title: "New review",
                        body: "Taylor K. left you a 5-star review: “Quick and friendly, would buy from again!”",
                        date: Date(timeIntervalSinceNow: -86400 * 2), isRead: true, actorName: "Taylor K."),
        AppNotification(kind: .sale, title: "Listing sold",
                        body: "Nice! Your “AirPods Pro (2nd gen)” is marked as sold.",
                        date: Date(timeIntervalSinceNow: -86400 * 3), isRead: true),
        AppNotification(kind: .system, title: "Welcome to Gotcha 🎉",
                        body: "You're verified as a student. Buy and sell safely with people on your campus.",
                        date: Date(timeIntervalSinceNow: -86400 * 5), isRead: true)
    ]
    #endif
}
