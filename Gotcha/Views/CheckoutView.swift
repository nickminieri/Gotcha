//
//  CheckoutView.swift
//  Gotcha
//
//  The "Reserve & pay at a safe meetup" flow — Gotcha's transaction moment.
//  No card processing: buyers reserve an item, lock in a safe campus meetup,
//  and pay the seller in person after inspecting it.
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct CheckoutView: View {
    let item: Item
    @ObservedObject var vm: MarketplaceViewModel
    @ObservedObject var messaging: MessagingViewModel
    @ObservedObject var notifications: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSpot: MeetupSpot = MeetupSpot.campusSpots[2] // Campus PD (safest)
    @State private var date = Date().addingTimeInterval(86_400)
    @State private var isReserving = false
    @State private var confirmed = false
    @State private var orderNumber = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                if confirmed {
                    confirmationScreen
                } else {
                    checkoutForm
                }
            }
            .navigationTitle(confirmed ? "Reserved" : "Reserve")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !confirmed {
                        Button("Cancel") { dismiss() }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Form
    private var checkoutForm: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    itemSummary
                    howItWorks
                    spotPicker
                    timePicker
                    priceBreakdown
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            // Sticky reserve button
            VStack(spacing: 8) {
                Button {
                    reserve()
                } label: {
                    ZStack {
                        if isReserving {
                            ProgressView().tint(.white)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Reserve Item")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Theme.accent.opacity(0.35), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(SpringButtonStyle())
                .disabled(isReserving)

                Text("You pay \(Self.priceString(item.price)) in person — no money changes hands until you've inspected the item.")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Theme.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(Theme.bg)
        }
    }

    private var itemSummary: some View {
        HStack(spacing: 14) {
            ListingImage(item: item, symbolSize: 28)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(2)
                Text("Sold by \(item.sellerName) · \(item.university)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Theme.textTertiary)
            }
            Spacer(minLength: 8)
            Text(Self.priceString(item.price))
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(14)
        .cardSurface()
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How Gotcha keeps this safe")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
            stepRow(1, "Reserve", "We hold the listing and notify the seller you're coming.")
            stepRow(2, "Meet on campus", "Trade at a public, well-lit, surveilled spot you choose below.")
            stepRow(3, "Inspect, then pay", "Check the item in person. Only hand over payment if it's right.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardSurface()
    }

    private func stepRow(_ n: Int, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Theme.accent.opacity(0.16)).frame(width: 26, height: 26)
                Text("\(n)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(Theme.accentSoft)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13.5, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Text(body)
                    .font(.system(size: 12.5, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var spotPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Meetup spot")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
            ForEach(MeetupSpot.campusSpots) { spot in
                let isSelected = spot == selectedSpot
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedSpot = spot }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: spot.symbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isSelected ? .white : Theme.accentSoft)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(isSelected ? Theme.accent : Theme.accent.opacity(0.14)))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(spot.name)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.textPrimary)
                            Text(spot.subtitle)
                                .font(.system(size: 11.5, design: .rounded))
                                .foregroundColor(Theme.textTertiary)
                        }
                        Spacer(minLength: 6)
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundColor(isSelected ? Theme.accent : Theme.textTertiary.opacity(0.5))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isSelected ? Theme.accent.opacity(0.10) : Theme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(isSelected ? Theme.accent.opacity(0.5) : Theme.hairline, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var timePicker: some View {
        HStack {
            Label("When", systemImage: "calendar")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
            Spacer()
            DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .tint(Theme.accent)
        }
        .padding(14)
        .cardSurface()
    }

    private var priceBreakdown: some View {
        VStack(spacing: 10) {
            row("Item price", Self.priceString(item.price), bold: false)
            row("Gotcha protection", "Free", bold: false, accent: true)
            Rectangle().fill(Theme.hairline).frame(height: 1)
            row("Pay at meetup", Self.priceString(item.price), bold: true)
        }
        .padding(16)
        .cardSurface()
    }

    private func row(_ label: String, _ value: String, bold: Bool, accent: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: bold ? 15 : 13.5, weight: bold ? .bold : .medium, design: .rounded))
                .foregroundColor(bold ? Theme.textPrimary : Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: bold ? 16 : 13.5, weight: bold ? .black : .semibold, design: .rounded))
                .foregroundColor(accent ? Color(red: 0.40, green: 0.80, blue: 0.55)
                                        : (bold ? Theme.textPrimary : Theme.textSecondary))
        }
    }

    // MARK: - Confirmation
    private var confirmationScreen: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ZStack {
                        Circle().fill(Color(red: 0.40, green: 0.80, blue: 0.55).opacity(0.16))
                            .frame(width: 96, height: 96)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(Color(red: 0.40, green: 0.80, blue: 0.55))
                    }
                    .padding(.top, 32)

                    VStack(spacing: 6) {
                        Text("You're all set!")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        Text("\(item.sellerName) has been notified. Meet up to inspect and pay.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    VStack(spacing: 0) {
                        receiptRow("Item", item.title)
                        receiptDivider
                        receiptRow("Pay at meetup", Self.priceString(item.price))
                        receiptDivider
                        receiptRow("Where", selectedSpot.name)
                        receiptDivider
                        receiptRow("When", date.formatted(date: .abbreviated, time: .shortened))
                        receiptDivider
                        receiptRow("Confirmation", orderNumber)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .cardSurface()
                    .padding(.horizontal, 16)

                    Label("Bring your campus ID. Inspect the item before paying. Never pay in advance.",
                          systemImage: "info.circle.fill")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Theme.textTertiary)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(SpringButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private func receiptRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13.5, design: .rounded))
                .foregroundColor(Theme.textSecondary)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 12)
    }

    private var receiptDivider: some View {
        Rectangle().fill(Theme.hairline).frame(height: 1)
    }

    // MARK: - Actions
    private func reserve() {
        isReserving = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        orderNumber = "GC-" + String(UUID().uuidString.prefix(6)).uppercased()

        // Record the reservation, lock in the meetup in chat, notify the buyer,
        // and take the listing off the market.
        vm.addReservation(for: item, spot: selectedSpot.name, date: date, confirmation: orderNumber)
        let convo = messaging.openConversationValue(for: item)
        messaging.scheduleMeetup(spot: selectedSpot.name, date: date, to: convo.id)
        notifications.add(
            kind: .sale,
            title: "Item reserved",
            body: "You reserved “\(item.title)”. Meet \(item.sellerName) at \(selectedSpot.name) to inspect and pay \(Self.priceString(item.price)).",
            actorName: item.sellerName
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            vm.markSold(item)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                isReserving = false
                confirmed = true
            }
        }
    }

    static func priceString(_ amount: Double) -> String {
        String(format: "$%.2f", amount)
    }
}
