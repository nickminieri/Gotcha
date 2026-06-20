//
//  MessagesView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

// MARK: - Messages Tab (conversation list)
struct MessagesTab: View {
    @ObservedObject var messaging: MessagingViewModel
    let onOpen: (Conversation) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Messages")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                if messaging.conversations.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.12))
                        Text("No messages yet")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.28))
                        Text("Message a seller from any listing\nto start a conversation.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.2))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    VStack(spacing: 10) {
                        ForEach(messaging.sortedConversations) { convo in
                            Button { onOpen(convo) } label: {
                                ConversationRow(conversation: convo)
                            }
                            .buttonStyle(SpringButtonStyle())
                            .contextMenu {
                                Button(role: .destructive) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        messaging.deleteConversation(convo.id)
                                    }
                                } label: {
                                    Label("Delete Conversation", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer().frame(height: 100)
            }
        }
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: conversation.category.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                Text(String(conversation.sellerName.prefix(1)))
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(conversation.sellerName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    if let last = conversation.lastMessage {
                        Text(last.date, style: .relative)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                Text(conversation.itemTitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.70, green: 0.52, blue: 1.00))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(conversation.lastMessage?.text ?? "")
                        .font(.system(size: 13,
                                      weight: conversation.unreadCount > 0 ? .semibold : .regular,
                                      design: .rounded))
                        .foregroundColor(.white.opacity(conversation.unreadCount > 0 ? 0.85 : 0.45))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(minWidth: 18, minHeight: 18)
                            .padding(.horizontal, 5)
                            .background(Capsule().fill(Color(red: 0.60, green: 0.40, blue: 1.00)))
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - Conversation Thread
struct ConversationView: View {
    let conversationID: UUID
    @ObservedObject var messaging: MessagingViewModel
    @ObservedObject var vm: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var showOffer = false
    @State private var showMeetup = false
    @State private var showReport = false
    @FocusState private var inputFocused: Bool

    private var conversation: Conversation? {
        messaging.conversation(id: conversationID)
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                safetyBanner

                // Messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(conversation?.messages ?? []) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    .onChange(of: conversation?.messages.count ?? 0) {
                        if let last = conversation?.messages.last {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        if let last = conversation?.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                inputBar
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            messaging.activeConversationID = conversationID
            messaging.markRead(conversationID)
        }
        .onDisappear {
            if messaging.activeConversationID == conversationID {
                messaging.activeConversationID = nil
            }
        }
        .sheet(isPresented: $showOffer) {
            MakeOfferSheet(itemTitle: conversation?.itemTitle ?? "this item", listPrice: nil) { amount in
                messaging.sendOffer(amount, to: conversationID)
            }
        }
        .sheet(isPresented: $showMeetup) {
            ScheduleMeetupSheet { spot, date in
                messaging.scheduleMeetup(spot: spot, date: date, to: conversationID)
            }
        }
        .sheet(isPresented: $showReport) {
            ReportSheet(subjectName: conversation?.sellerName ?? "this user") { reason in
                if let seller = conversation?.sellerName { vm.report(sellerName: seller, reason: reason) }
                dismiss()
            }
        }
    }

    // MARK: - Safety banner
    private var safetyBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 0.30, green: 0.80, blue: 0.55))
            Text("Keep it on Gotcha — never share phone numbers, passwords, or payment info.")
                .font(.system(size: 11.5, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textSecondary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color(red: 0.30, green: 0.80, blue: 0.55).opacity(0.10))
    }

    private var header: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }

                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: (conversation?.category ?? .other).gradientColors,
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 40, height: 40)
                    Text(String((conversation?.sellerName ?? "?").prefix(1)))
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(conversation?.sellerName ?? "")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.30, green: 0.80, blue: 0.55))
                    }
                    Text(conversation?.itemTitle ?? "")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(1)
                }
                Spacer()
                Menu {
                    Button(role: .destructive) { showReport = true } label: {
                        Label("Report", systemImage: "flag")
                    }
                    if let seller = conversation?.sellerName {
                        Button(role: .destructive) {
                            vm.block(seller); dismiss()
                        } label: {
                            Label("Block \(seller)", systemImage: "hand.raised")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)

            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
        }
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
            HStack(spacing: 10) {
                Menu {
                    Button { showOffer = true } label: {
                        Label("Make an Offer", systemImage: "dollarsign.circle")
                    }
                    Button { showMeetup = true } label: {
                        Label("Schedule Safe Meetup", systemImage: "mappin.and.ellipse")
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.accent)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Theme.accent.opacity(0.14)))
                }

                TextField(
                    "",
                    text: $draft,
                    prompt: Text("Message...").foregroundColor(.white.opacity(0.3)),
                    axis: .vertical
                )
                .lineLimit(1...4)
                .foregroundColor(.white)
                .font(.system(size: 15, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.white.opacity(0.08)))
                .focused($inputFocused)

                Button { sendDraft() } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                         Color(red: 0.85, green: 0.55, blue: 1.00)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .opacity(draft.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        .background(Theme.bg)
    }

    private func sendDraft() {
        messaging.send(draft, to: conversationID)
        draft = ""
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message

    private var bubbleStyle: AnyShapeStyle {
        if message.isFromMe {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                         Color(red: 0.72, green: 0.45, blue: 1.00)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        } else {
            return AnyShapeStyle(Color.white.opacity(0.10))
        }
    }

    var body: some View {
        switch message.resolvedKind {
        case .system:
            Text(message.text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.06)))
                .frame(maxWidth: .infinity, alignment: .center)

        case .offer:
            card(alignment: message.isFromMe ? .trailing : .leading) {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Offer", systemImage: "dollarsign.circle.fill")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Text(String(format: "$%.2f", message.offerAmount ?? 0))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    offerStatusLabel
                }
            }

        case .meetup:
            card(alignment: message.isFromMe ? .trailing : .leading) {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Safe Meetup", systemImage: "mappin.circle.fill")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Text(message.meetupSpot ?? "Campus")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    if let date = message.meetupDate {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }

        case .text:
            HStack {
                if message.isFromMe { Spacer(minLength: 50) }
                Text(message.text)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleStyle, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                if !message.isFromMe { Spacer(minLength: 50) }
            }
            .frame(maxWidth: .infinity, alignment: message.isFromMe ? .trailing : .leading)
        }
    }

    @ViewBuilder
    private var offerStatusLabel: some View {
        switch message.offerStatus ?? .pending {
        case .pending:
            Text("Pending…")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        case .accepted:
            Label("Accepted", systemImage: "checkmark.circle.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.40, green: 0.95, blue: 0.6))
        case .declined:
            Label("Declined", systemImage: "xmark.circle.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Theme.sold)
        }
    }

    @ViewBuilder
    private func card<Content: View>(alignment: HorizontalAlignment, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            if message.isFromMe { Spacer(minLength: 40) }
            content()
                .padding(14)
                .frame(minWidth: 150, alignment: .leading)
                .background(bubbleStyle, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(message.isFromMe ? 0 : 0.08), lineWidth: 1)
                )
            if !message.isFromMe { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: message.isFromMe ? .trailing : .leading)
    }
}
