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
    let onMessage: (Item) -> Void
    var onSeller: (SellerRef) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss

    // Always reflects latest favorite state from the VM
    private var current: Item { vm.currentState(of: item) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.07, green: 0.07, blue: 0.10)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Hero photo / gradient area
                    ZStack(alignment: .top) {
                        ListingImage(item: item, symbolSize: 110)
                            .frame(maxWidth: .infinity)
                            .frame(height: 320)
                            .overlay {
                                if current.isSold {
                                    ZStack {
                                        Color.black.opacity(0.5)
                                        Text("SOLD")
                                            .font(.system(size: 28, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 26)
                                            .padding(.vertical, 10)
                                            .background(Capsule().fill(Color(red: 1.0, green: 0.3, blue: 0.4)))
                                    }
                                }
                            }
                            .clipped()
                            .ignoresSafeArea(edges: .top)

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
                                .foregroundColor(.white.opacity(current.isSold ? 0.4 : 1))
                                .strikethrough(current.isSold, color: .white.opacity(0.4))
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

                        Button {
                            onSeller(SellerRef(name: item.sellerName, university: item.university))
                        } label: {
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
                                    if let avg = vm.averageRating(for: item.sellerName) {
                                        HStack(spacing: 5) {
                                            StarsView(rating: avg, size: 11)
                                            Text(String(format: "%.1f · %d reviews", avg, vm.reviewCount(for: item.sellerName)))
                                                .font(.system(size: 12, design: .rounded))
                                                .foregroundColor(.white.opacity(0.45))
                                        }
                                    } else {
                                        Text(item.university)
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.white.opacity(0.38))
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.3))
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(SpringButtonStyle())
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
                        onMessage(item)
                    } label: {
                        Text(current.isSold ? "Item Sold" : "Message Seller")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                Group {
                                    if current.isSold {
                                        Color.white.opacity(0.12)
                                    } else {
                                        LinearGradient(
                                            colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                                     Color(red: 0.85, green: 0.55, blue: 1.00)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(SpringButtonStyle())
                    .disabled(current.isSold)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
                .background(Color(red: 0.07, green: 0.07, blue: 0.10))
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: Item.sampleItems[0], vm: MarketplaceViewModel(), onMessage: { _ in })
    }
    .environmentObject(AppState())
}
