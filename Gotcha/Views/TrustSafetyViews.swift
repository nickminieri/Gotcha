//
//  TrustSafetyViews.swift
//  Gotcha
//
//  Trust badges, reporting, offers, and safe-meetup scheduling — the
//  student-safety differentiators surfaced by the marketplace research.
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

// MARK: - Trust Badge
struct TrustBadge: View {
    enum Kind { case student, id }
    let kind: Kind
    var compact: Bool = false

    private var label: String { kind == .student ? "Student Verified" : "ID Verified" }
    private var symbol: String { kind == .student ? "checkmark.seal.fill" : "person.badge.shield.checkmark.fill" }
    private var tint: Color { kind == .student ? Color(red: 0.30, green: 0.80, blue: 0.55) : Theme.accent }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: compact ? 10 : 11, weight: .bold))
            if !compact {
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
        }
        .foregroundColor(tint)
        .padding(.horizontal, compact ? 6 : 9)
        .padding(.vertical, compact ? 3 : 5)
        .background(Capsule().fill(tint.opacity(0.14)))
    }
}

// MARK: - Report Sheet
struct ReportSheet: View {
    let subjectName: String
    let onReport: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private let reasons = [
        ("exclamationmark.triangle.fill", "Scam or fraud"),
        ("hand.raised.fill", "Harassment or threats"),
        ("nosign", "Prohibited or fake item"),
        ("eye.trianglebadge.exclamationmark.fill", "Inappropriate content"),
        ("ellipsis.circle.fill", "Something else")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Why are you reporting \(subjectName)?")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.top, 8)

                    VStack(spacing: 10) {
                        ForEach(reasons, id: \.1) { icon, reason in
                            Button {
                                onReport(reason)
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: icon)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Theme.sold)
                                        .frame(width: 34, height: 34)
                                        .background(Theme.sold.opacity(0.13))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    Text(reason)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(14)
                                .cardSurface(cornerRadius: 14)
                            }
                            .buttonStyle(SpringButtonStyle())
                        }
                    }

                    Text("Reports are tied to your verified student identity and reviewed by the Gotcha safety team. The seller is hidden from you immediately.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Theme.textTertiary)
                        .padding(.top, 4)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.white.opacity(0.6))
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(28)
    }
}

// MARK: - Make Offer Sheet
struct MakeOfferSheet: View {
    let itemTitle: String
    var listPrice: Double?
    let onSubmit: (Double) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var amountText = ""

    private var amount: Double? { Double(amountText.trimmingCharacters(in: .whitespaces)) }
    private var canSend: Bool { (amount ?? 0) > 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Make an offer on\n\(itemTitle)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    HStack(spacing: 2) {
                        Text("$")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(Theme.textTertiary)
                        TextField("", text: $amountText,
                                  prompt: Text("0").foregroundColor(Theme.textTertiary))
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                            .fixedSize()
                    }

                    if let listPrice {
                        Text("Listed at \(String(format: "$%.2f", listPrice))")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(Theme.textTertiary)
                    }

                    Button {
                        if let amount { onSubmit(amount); dismiss() }
                    } label: {
                        Text("Send Offer")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Theme.accentGradient)
                            .clipShape(Capsule())
                            .opacity(canSend ? 1 : 0.4)
                    }
                    .disabled(!canSend)
                    .padding(.top, 4)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.white.opacity(0.6))
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
        .presentationCornerRadius(28)
    }
}

// MARK: - Schedule Meetup Sheet
struct ScheduleMeetupSheet: View {
    let onSubmit: (String, Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSpot: MeetupSpot = MeetupSpot.campusSpots[0]
    @State private var date = Date().addingTimeInterval(3600)

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Label("Choose a safe, public campus spot", systemImage: "shield.lefthalf.filled")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.30, green: 0.80, blue: 0.55))
                            .padding(.top, 8)

                        VStack(spacing: 10) {
                            ForEach(MeetupSpot.campusSpots) { spot in
                                let selected = spot == selectedSpot
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedSpot = spot
                                    }
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: spot.symbol)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(selected ? .white : Theme.accent)
                                            .frame(width: 38, height: 38)
                                            .background(selected ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.accent.opacity(0.14)))
                                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(spot.name)
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                            Text(spot.subtitle)
                                                .font(.system(size: 12, design: .rounded))
                                                .foregroundColor(Theme.textTertiary)
                                        }
                                        Spacer()
                                        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 18))
                                            .foregroundColor(selected ? Theme.accent : Theme.textTertiary)
                                    }
                                    .padding(12)
                                    .cardSurface(cornerRadius: 14)
                                }
                                .buttonStyle(SpringButtonStyle())
                            }
                        }

                        DatePicker("When", selection: $date, in: Date()...)
                            .datePickerStyle(.compact)
                            .tint(Theme.accent)
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .padding(14)
                            .cardSurface(cornerRadius: 14)

                        Button {
                            onSubmit(selectedSpot.name, date)
                            dismiss()
                        } label: {
                            Text("Propose Meetup")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Theme.accentGradient)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 2)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Schedule Meetup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.white.opacity(0.6))
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationCornerRadius(28)
    }
}
