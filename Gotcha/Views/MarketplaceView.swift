//
//  MarketplaceView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

// MARK: - Marketplace Root
struct MarketplaceView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = MarketplaceViewModel()
    @StateObject private var messaging = MessagingViewModel()
    @StateObject private var notifications = NotificationsViewModel()
    @State private var path = NavigationPath()
    @State private var didConfigureUser = false
    @State private var showNotifications = false
    @State private var checkoutItem: Item?

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Theme.bg
                    .ignoresSafeArea()

                Group {
                    switch vm.selectedTab {
                    case .explore:
                        ExploreTab(vm: vm, notifications: notifications,
                                   onBell: { showNotifications = true }) { path.append($0) }
                    case .favorites:
                        FavoritesTab(vm: vm) { path.append($0) }
                    case .messages:
                        MessagesTab(messaging: messaging) { path.append($0) }
                    case .profile:
                        UserProfileView(vm: vm)
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.18), value: vm.selectedTab)
            }
            .safeAreaInset(edge: .bottom) {
                FloatingTabBar(selectedTab: $vm.selectedTab, messagesBadge: messaging.totalUnread)
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item, vm: vm, onMessage: { selected in
                    path.append(messaging.openConversationValue(for: selected))
                }, onSeller: { seller in
                    path.append(seller)
                }, onReserve: { selected in
                    checkoutItem = selected
                })
            }
            .navigationDestination(for: Conversation.self) { convo in
                ConversationView(conversationID: convo.id, messaging: messaging, vm: vm)
            }
            .navigationDestination(for: SellerRef.self) { seller in
                SellerProfileView(seller: seller, vm: vm)
            }
            .sheet(isPresented: $vm.isPresentingCreateListing) {
                CreateListingView(vm: vm)
            }
            .sheet(item: $vm.editingListing) { item in
                CreateListingView(vm: vm, editingItem: item)
            }
        }
        // These two are attached to the NavigationStack (a different view than the
        // sheets above) so multiple presentations don't compete on one view.
        .sheet(isPresented: $showNotifications) {
            NotificationsView(notifications: notifications)
        }
        .sheet(item: $checkoutItem) { item in
            CheckoutView(item: item, vm: vm, messaging: messaging, notifications: notifications)
        }
        .onAppear {
            // Route messaging activity (offer accepts, meetup confirms) into the feed.
            messaging.onActivity = { [weak notifications] note in
                notifications?.add(note)
            }
            // Derive the signed-in user's profile from their campus email, once.
            guard !didConfigureUser else { return }
            didConfigureUser = true
            // Derive from the login email only when there's no saved profile yet.
            if !vm.hasStoredProfile, let email = appState.signedInEmail, !email.isEmpty {
                vm.currentUser = User.fromCampusEmail(email)
            }
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-uiOpenFirstConversation"),
               let first = messaging.sortedConversations.first {
                path.append(first)
            }
            if ProcessInfo.processInfo.arguments.contains("-uiOpenSeller") {
                path.append(SellerRef(name: "Chris L.", university: "MIT"))
            }
            if ProcessInfo.processInfo.arguments.contains("-uiOpenFirstItem"),
               let item = vm.items.first(where: { !$0.isSold && !vm.isOwnListing($0) }) {
                path.append(item)
            }
            if ProcessInfo.processInfo.arguments.contains("-uiPresentNotifications") {
                showNotifications = true
            }
            if ProcessInfo.processInfo.arguments.contains("-uiPresentCheckout") {
                checkoutItem = vm.items.first(where: { !$0.isSold && !vm.isOwnListing($0) }) ?? vm.items.first
            }
            #endif
        }
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: MarketplaceViewModel.Tab
    var messagesBadge: Int = 0

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MarketplaceViewModel.Tab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: isSelected ? tab.symbols.filled : tab.symbols.default)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(height: 24)

                            if tab == .messages && messagesBadge > 0 {
                                Text("\(messagesBadge)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 16, minHeight: 16)
                                    .padding(.horizontal, 3)
                                    .background(Capsule().fill(Theme.sold))
                                    .overlay(Capsule().strokeBorder(Theme.elevated, lineWidth: 1.5))
                                    .offset(x: 13, y: -7)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(isSelected ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.textTertiary))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Theme.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(Theme.stroke, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.45), radius: 18, x: 0, y: 8)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
}

// MARK: - Explore Tab
struct ExploreTab: View {
    @ObservedObject var vm: MarketplaceViewModel
    @ObservedObject var notifications: NotificationsViewModel
    let onBell: () -> Void
    let onSelect: (Item) -> Void
    @State private var showFilters = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("GOTCHA")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(Theme.accentGradient)
                        Text("What's for sale?")
                            .font(.system(size: 27, weight: .heavy, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 10) {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onBell()
                        } label: {
                            Image(systemName: "bell")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Theme.bgRaised))
                                .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 1))
                                .overlay(alignment: .topTrailing) {
                                    if notifications.hasUnread {
                                        Text("\(notifications.unreadCount)")
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .frame(minWidth: 16, minHeight: 16)
                                            .padding(.horizontal, 3)
                                            .background(Capsule().fill(Theme.sold))
                                            .overlay(Capsule().strokeBorder(Theme.bg, lineWidth: 1.5))
                                            .offset(x: 4, y: -3)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                        }
                        .buttonStyle(SpringButtonStyle())
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            vm.isPresentingCreateListing = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Theme.accentGradient))
                                .shadow(color: Theme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(SpringButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Theme.textTertiary)
                        .font(.system(size: 15, weight: .semibold))
                    TextField(
                        "",
                        text: $vm.searchText,
                        prompt: Text("Search listings...")
                            .foregroundColor(Theme.textTertiary)
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
                .padding(.vertical, 14)
                .cardSurface(cornerRadius: 16, fill: Theme.bgRaised)
                .padding(.horizontal, 20)
                .padding(.bottom, 18)

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
                .padding(.bottom, 16)

                // Result count + sort
                HStack {
                    Text("^[\(vm.filteredItems.count) listing](inflect: true)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                    Button {
                        showFilters = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 12, weight: .bold))
                            if vm.activeFilterCount > 0 {
                                Text("\(vm.activeFilterCount)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(vm.activeFilterCount > 0 ? .white : Color(red: 0.70, green: 0.52, blue: 1.00))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(vm.activeFilterCount > 0
                                ? Color(red: 0.60, green: 0.40, blue: 1.00)
                                : Color(red: 0.70, green: 0.52, blue: 1.00).opacity(0.12))
                        )
                    }
                    .padding(.trailing, 8)
                    Menu {
                        Picker("Sort", selection: $vm.sortOption) {
                            ForEach(MarketplaceViewModel.SortOption.allCases) { option in
                                Label(option.rawValue, systemImage: option.symbol).tag(option)
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 11, weight: .bold))
                            Text(vm.sortOption.rawValue)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color(red: 0.70, green: 0.52, blue: 1.00))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(Color(red: 0.70, green: 0.52, blue: 1.00).opacity(0.12))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

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
                                onSelect(item)
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
        .sheet(isPresented: $showFilters) {
            FilterSheet(vm: vm)
        }
        .onAppear {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-uiPresentFilters") {
                showFilters = true
            }
            #endif
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
            .foregroundColor(isSelected ? .white : Theme.textSecondary)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        Capsule().fill(Theme.accentGradient)
                    } else {
                        Capsule().fill(Theme.bgRaised)
                        Capsule().strokeBorder(Theme.hairline, lineWidth: 1)
                    }
                }
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

                // Visual area — photo or gradient + icon
                ZStack(alignment: .topTrailing) {
                    ListingImage(item: item, symbolSize: 46)
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .overlay(
                            // Subtle bottom scrim grounds the art and improves legibility.
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.28)],
                                startPoint: .center, endPoint: .bottom
                            )
                        )
                        .overlay {
                            if item.isSold {
                                ZStack {
                                    Color.black.opacity(0.5)
                                    Text("SOLD")
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .tracking(0.5)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(Capsule().fill(Theme.sold))
                                }
                            }
                        }
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: Theme.radius,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: Theme.radius
                            )
                        )

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
                            .foregroundColor(item.isFavorite ? Theme.sold : .white)
                            .frame(width: 30, height: 30)
                            .background(Color.black.opacity(0.28))
                            .background(.ultraThinMaterial, in: Circle())
                            .clipShape(Circle())
                            .scaleEffect(heartBouncing ? 1.35 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                }

                // Info area
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 13.5, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(item.sellerName) · \(item.university)")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Theme.textTertiary)
                        .lineLimit(1)

                    HStack(alignment: .center) {
                        Text(String(format: "$%.2f", item.price))
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)
                            .fixedSize()
                        Spacer(minLength: 6)
                        // Condition pill
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.condition.color)
                                .frame(width: 6, height: 6)
                            Text(item.condition.rawValue)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(item.condition.color)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(item.condition.color.opacity(0.12)))
                    }
                    .padding(.top, 3)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .cardSurface()
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Favorites Tab
struct FavoritesTab: View {
    @ObservedObject var vm: MarketplaceViewModel
    let onSelect: (Item) -> Void

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
                                onSelect(item)
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

// MARK: - Preview
#Preview {
    MarketplaceView()
        .environmentObject(AppState())
}
