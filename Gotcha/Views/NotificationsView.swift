//
//  NotificationsView.swift
//  Gotcha
//
//  The in-app activity feed, presented from the bell in the Explore header.
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var notifications: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if notifications.notifications.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(notifications.sorted) { note in
                                NotificationRow(note: note)
                                    .onTapGesture { notifications.markRead(note.id) }
                                    .contextMenu {
                                        if !note.isRead {
                                            Button { notifications.markRead(note.id) } label: {
                                                Label("Mark as read", systemImage: "checkmark.circle")
                                            }
                                        }
                                        Button(role: .destructive) {
                                            notifications.delete(note.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: notifications.notifications)
                    }
                }
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.accentSoft)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            notifications.markAllRead()
                        } label: {
                            Label("Mark all as read", systemImage: "checkmark.circle")
                        }
                        .disabled(!notifications.hasUnread)

                        Button(role: .destructive) {
                            notifications.clearAll()
                        } label: {
                            Label("Clear all", systemImage: "trash")
                        }
                        .disabled(notifications.notifications.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.accentSoft)
                    }
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bell.slash")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.14))
            Text("You're all caught up")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
            Text("Offers, messages, reviews, and meetups\nwill show up here.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white.opacity(0.2))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Row
private struct NotificationRow: View {
    let note: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon chip
            ZStack {
                Circle()
                    .fill(note.kind.tint.opacity(0.16))
                    .frame(width: 42, height: 42)
                Image(systemName: note.kind.symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(note.kind.tint)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(note.title)
                        .font(.system(size: 14.5, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                    Spacer(minLength: 6)
                    Text(note.relativeTime)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.textTertiary)
                }
                Text(note.body)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(1)
            }

            // Unread dot
            if !note.isRead {
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(14)
        .cardSurface(fill: note.isRead ? Theme.card : Theme.bgRaised)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius, style: .continuous)
                .strokeBorder(note.isRead ? Color.clear : Theme.accent.opacity(0.22), lineWidth: 1)
        )
    }
}

#Preview {
    let vm = NotificationsViewModel()
    return NotificationsView(notifications: vm)
}
