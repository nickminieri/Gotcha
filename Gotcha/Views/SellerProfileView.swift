//
//  SellerProfileView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct SellerProfileView: View {
    let seller: SellerRef
    @ObservedObject var vm: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showWriteReview = false
    @State private var showReport = false

    private var sellerReviews: [Review] { vm.reviews(for: seller.name) }
    private var average: Double? { vm.averageRating(for: seller.name) }
    private var isSelf: Bool { seller.name == vm.currentUser.name }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header

                    if sellerReviews.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "star.bubble")
                                .font(.system(size: 42))
                                .foregroundColor(.white.opacity(0.14))
                            Text("No reviews yet")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(sellerReviews) { review in
                                ReviewRow(review: review)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            if !isSelf {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) { showReport = true } label: {
                            Label("Report", systemImage: "flag")
                        }
                        Button(role: .destructive) { vm.block(seller.name); dismiss() } label: {
                            Label("Block", systemImage: "hand.raised")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(seller: seller, vm: vm)
        }
        .sheet(isPresented: $showReport) {
            ReportSheet(subjectName: seller.name) { reason in
                vm.report(sellerName: seller.name, reason: reason)
                dismiss()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                 Color(red: 0.85, green: 0.55, blue: 1.00)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 84, height: 84)
                Text(String(seller.name.prefix(1)))
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 8)

            VStack(spacing: 5) {
                Text(seller.name)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.50, green: 0.32, blue: 1.00))
                    Text(seller.university)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                }
                TrustBadge(kind: .student)
                    .padding(.top, 2)
            }

            // Rating summary
            HStack(spacing: 8) {
                if let average {
                    StarsView(rating: average, size: 16)
                    Text(String(format: "%.1f", average))
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("(\(sellerReviews.count))")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                } else {
                    Text("No ratings yet")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            if !isSelf {
                Button { showWriteReview = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Write a Review")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(LinearGradient(
                            colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                     Color(red: 0.85, green: 0.55, blue: 1.00)],
                            startPoint: .leading, endPoint: .trailing))
                    )
                }
                .buttonStyle(SpringButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
    }
}

// MARK: - Review Row
struct ReviewRow: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 36, height: 36)
                    Text(String(review.reviewerName.prefix(1)))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    StarsView(rating: Double(review.rating), size: 11)
                }
                Spacer()
                Text(review.date, style: .date)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }
            if !review.text.isEmpty {
                Text(review.text)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - Stars (display)
struct StarsView: View {
    let rating: Double
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: symbol(for: i))
                    .font(.system(size: size))
                    .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.2))
            }
        }
    }

    private func symbol(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 1 { return "star.fill" }
        if value >= 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }
}

// MARK: - Write Review
struct WriteReviewView: View {
    let seller: SellerRef
    @ObservedObject var vm: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var rating = 5
    @State private var text = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("How was your experience with \(seller.name)?")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    StarPicker(rating: $rating)

                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("Share details of your experience...")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white.opacity(0.22))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                        }
                        TextEditor(text: $text)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .frame(minHeight: 120, alignment: .topLeading)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.07))
                    )

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.6))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        vm.addReview(sellerName: seller.name, rating: rating, text: text)
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.70, green: 0.52, blue: 1.00))
                    .fontWeight(.semibold)
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

// MARK: - Stars (interactive)
struct StarPicker: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: 34))
                    .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.2))
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            rating = star
                        }
                    }
            }
        }
    }
}
