//
//  ItemDetailView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @ObservedObject var vm: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showMessageSheet = false

    // Always reflects latest favorite state from the VM
    private var current: Item { vm.currentState(of: item) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.07, green: 0.07, blue: 0.10)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Hero gradient area
                    ZStack(alignment: .top) {
                        LinearGradient(
                            colors: item.category.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 320)
                        .ignoresSafeArea(edges: .top)

                        Image(systemName: item.category.symbol)
                            .font(.system(size: 110, weight: .semibold))
                            .foregroundColor(.white.opacity(0.22))
                            .frame(maxWidth: .infinity)
                            .frame(height: 320)

                        // Back + favorite row
                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            Spacer()
                            Button {
                                vm.toggleFavorite(item)
                            } label: {
                                Image(systemName: current.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(current.isFavorite ? Color(red: 1.0, green: 0.3, blue: 0.4) : .white)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: current.isFavorite)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    }

                    // Main content card
                    VStack(alignment: .leading, spacing: 0) {

                        // Title + price
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text(item.category.rawValue)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.38))
                            }
                            Spacer()
                            Text(String(format: "$%.2f", item.price))
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 24)

                        // Condition badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.condition.color)
                                .frame(width: 7, height: 7)
                            Text(item.condition.rawValue)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(item.condition.color)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(item.condition.color.opacity(0.13))
                        .clipShape(Capsule())
                        .padding(.top, 14)

                        // Divider
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.vertical, 20)

                        // Description
                        if !item.description.isEmpty {
                            Text("About this item")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text(item.description)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white.opacity(0.58))
                                .lineSpacing(5)
                                .padding(.top, 8)

                            Rectangle()
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 1)
                                .padding(.vertical, 20)
                        }

                        // Seller card
                        Text("Seller")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        HStack(spacing: 14) {
                            // Avatar with first initial
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: item.category.gradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 48, height: 48)
                                Text(String(item.sellerName.prefix(1)))
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.sellerName)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(item.university)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.white.opacity(0.38))
                            }
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(red: 0.50, green: 0.32, blue: 1.00))
                                .font(.system(size: 22))
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.top, 12)

                        // Posted date
                        Text("Listed \(item.postedDate, style: .relative) ago")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.white.opacity(0.22))
                            .padding(.top, 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 130) // clearance for action bar
                }
            }
            .ignoresSafeArea(edges: .top)

            // Sticky action bar
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                HStack(spacing: 12) {
                    Button {
                        vm.toggleFavorite(item)
                    } label: {
                        Image(systemName: current.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(current.isFavorite ? Color(red: 1.0, green: 0.3, blue: 0.4) : .white)
                            .frame(width: 54, height: 54)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: current.isFavorite)
                    }
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showMessageSheet = true
                    } label: {
                        Text("Message Seller")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                             Color(red: 0.85, green: 0.55, blue: 1.00)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(SpringButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
                .background(Color(red: 0.07, green: 0.07, blue: 0.10))
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showMessageSheet) {
            MessageComingSoonSheet()
        }
    }
}

// MARK: - Message Coming Soon Sheet
struct MessageComingSoonSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 44))
                .foregroundColor(Color(red: 0.70, green: 0.52, blue: 1.00))
                .padding(.top, 8)

            Text("Messaging Coming Soon")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Direct messaging with sellers\nwill be available in a future update.")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text("Got it")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.09, green: 0.09, blue: 0.13))
        .presentationDetents([.height(360)])
        .presentationCornerRadius(28)
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: Item.sampleItems[0], vm: MarketplaceViewModel())
    }
    .environmentObject(AppState())
}
