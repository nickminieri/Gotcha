//
//  MarketplaceView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

// MARK: - Marketplace Root
struct MarketplaceView: View {
    @StateObject private var vm = MarketplaceViewModel()
    @State private var selectedItem: Item?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.10)
                    .ignoresSafeArea()

                Group {
                    switch vm.selectedTab {
                    case .explore:
                        ExploreTab(vm: vm, selectedItem: $selectedItem)
                    case .favorites:
                        FavoritesTab(vm: vm, selectedItem: $selectedItem)
                    case .messages:
                        MessagesTab()
                    case .profile:
                        UserProfileView()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.18), value: vm.selectedTab)
            }
            .safeAreaInset(edge: .bottom) {
                FloatingTabBar(selectedTab: $vm.selectedTab)
            }
            .navigationDestination(item: $selectedItem) { item in
                ItemDetailView(item: item, vm: vm)
            }
        }
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: MarketplaceViewModel.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MarketplaceViewModel.Tab.allCases, id: \.self) { tab in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: selectedTab == tab
                              ? tab.symbols.filled
                              : tab.symbols.default)
                            .font(.system(size: 22, weight: .semibold))
                            .scaleEffect(selectedTab == tab ? 1.10 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(
                        selectedTab == tab
                        ? Color(red: 0.70, green: 0.52, blue: 1.00)
                        : Color.white.opacity(0.35)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Explore Tab
struct ExploreTab: View {
    @ObservedObject var vm: MarketplaceViewModel
    @Binding var selectedItem: Item?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Gotcha")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.70, green: 0.52, blue: 1.00))
                        Text("What's for sale?")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button { } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.white.opacity(0.38))
                        .font(.system(size: 15, weight: .medium))
                    TextField(
                        "",
                        text: $vm.searchText,
                        prompt: Text("Search listings...")
                            .foregroundColor(.white.opacity(0.22))
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 15, design: .rounded))
                    .autocorrectionDisabled()
                    if !vm.searchText.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                vm.searchText = ""
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Item.Category.allCases.filter { $0 != .other }) { category in
                            CategoryChip(
                                category: category,
                                isSelected: vm.selectedCategory == category
                            ) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    vm.selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)

                // Items grid
                if vm.filteredItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.15))
                        Text("No listings found")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.28))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(vm.filteredItems) { item in
                            ItemCard(item: vm.currentState(of: item)) {
                                selectedItem = item
                            } onFavorite: {
                                vm.toggleFavorite(item)
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

// MARK: - Category Chip
struct CategoryChip: View {
    let category: Item.Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.symbol)
                    .font(.system(size: 11, weight: .semibold))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.45))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(LinearGradient(
                            colors: category.gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        : AnyShapeStyle(Color.white.opacity(0.08))
                    )
            )
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Item Card
struct ItemCard: View {
    let item: Item
    let onTap: () -> Void
    let onFavorite: () -> Void
    @State private var heartBouncing = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {

                // Visual area — gradient + icon
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: item.category.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 140)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 14,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 14
                        )
                    )

                    Image(systemName: item.category.symbol)
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.white.opacity(0.28))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .frame(height: 140)

                    // Favorite button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.45)) {
                            heartBouncing = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            heartBouncing = false
                        }
                        onFavorite()
                    } label: {
                        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(item.isFavorite ? Color(red: 1.0, green: 0.3, blue: 0.4) : .white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .scaleEffect(heartBouncing ? 1.35 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }

                // Info area
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(item.sellerName) · \(item.university)")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.38))
                        .lineLimit(1)

                    HStack(alignment: .bottom) {
                        Text(String(format: "$%.2f", item.price))
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        // Condition dot
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.condition.color)
                                .frame(width: 6, height: 6)
                            Text(item.condition.rawValue)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(item.condition.color)
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 11)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.13, green: 0.13, blue: 0.17))
            )
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Favorites Tab
struct FavoritesTab: View {
    @ObservedObject var vm: MarketplaceViewModel
    @Binding var selectedItem: Item?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Saved")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                if vm.favoriteItems.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 44))
                            .foregroundColor(.white.opacity(0.14))
                        Text("Nothing saved yet")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.28))
                        Text("Tap the heart on any listing\nto save it here.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.2))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(vm.favoriteItems) { item in
                            ItemCard(item: vm.currentState(of: item)) {
                                selectedItem = item
                            } onFavorite: {
                                vm.toggleFavorite(item)
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

// MARK: - Messages Tab
struct MessagesTab: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 52))
                .foregroundColor(.white.opacity(0.12))
            Text("Messages")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Chat with buyers and sellers\nis coming soon.")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.white.opacity(0.38))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
#Preview {
    MarketplaceView()
        .environmentObject(AppState())
}
