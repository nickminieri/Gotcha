//
//  UserProfileView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var vm: MarketplaceViewModel
    @EnvironmentObject var appState: AppState
    @State private var pendingDelete: Item?
    private var user: User { vm.currentUser }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Header label
                Text("Profile")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 28)

                // Avatar + identity
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                         Color(red: 0.85, green: 0.55, blue: 1.00)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 84, height: 84)
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    VStack(spacing: 5) {
                        Text(user.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.50, green: 0.32, blue: 1.00))
                            Text(user.university)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white.opacity(0.45))
                        }
                    }
                }
                .padding(.bottom, 28)

                // Stats row
                HStack(spacing: 0) {
                    ProfileStat(value: "\(user.listedCount)", label: "Listed")
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: user.listedCount)
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 1, height: 36)
                    ProfileStat(value: String(format: "%.1f★", user.rating), label: "Rating")
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 1, height: 36)
                    ProfileStat(value: "\(user.reviewCount)", label: "Reviews")
                }
                .padding(.vertical, 20)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

                // My Listings
                if !vm.myListings.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Listings")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(vm.myListings) { item in
                            MyListingRow(
                                item: item,
                                onEdit: { vm.editingListing = item },
                                onDelete: { pendingDelete = item },
                                onToggleSold: { vm.toggleSold(item) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }

                // Menu
                VStack(spacing: 10) {
                    ProfileMenuItem(
                        icon: "plus.circle.fill",
                        label: "List an Item",
                        color: Color(red: 0.50, green: 0.32, blue: 1.00)
                    ) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        vm.isPresentingCreateListing = true
                    }
                    ProfileMenuItem(
                        icon: "clock.arrow.circlepath",
                        label: "Purchase History",
                        color: Color(red: 0.10, green: 0.65, blue: 0.90)
                    )
                    ProfileMenuItem(
                        icon: "bell.fill",
                        label: "Notifications",
                        color: Color(red: 0.95, green: 0.65, blue: 0.15)
                    )
                    ProfileMenuItem(
                        icon: "gearshape.fill",
                        label: "Settings",
                        color: Color(red: 0.50, green: 0.50, blue: 0.60)
                    )
                    ProfileMenuItem(
                        icon: "questionmark.circle.fill",
                        label: "Help & Support",
                        color: Color(red: 0.20, green: 0.80, blue: 0.50)
                    )
                }
                .padding(.horizontal, 20)

                // Logout
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    appState.logout()
                } label: {
                    Text("Log out")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.38))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 1.0, green: 0.35, blue: 0.38).opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
        }
        .confirmationDialog(
            "Delete this listing?",
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: pendingDelete
        ) { item in
            Button("Delete", role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    vm.deleteListing(item)
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        } message: { item in
            Text("\"\(item.title)\" will be permanently removed.")
        }
    }
}

// MARK: - Profile Stat Cell
struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.38))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let label: String
    let color: Color
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 38, height: 38)
                    .background(color.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(label)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.20))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - My Listing Row
struct MyListingRow: View {
    let item: Item
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleSold: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ListingImage(item: item, symbolSize: 22)
                .frame(width: 56, height: 56)
                .overlay {
                    if item.isSold {
                        Color.black.opacity(0.5)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if item.isSold {
                        Text("SOLD")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color(red: 1.0, green: 0.3, blue: 0.4)))
                    }
                }
                Text(item.category.rawValue)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.38))
            }
            Spacer()
            Text(String(format: "$%.2f", item.price))
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(item.isSold ? 0.4 : 1))
                .strikethrough(item.isSold, color: .white.opacity(0.4))

            Menu {
                Button { onToggleSold() } label: {
                    Label(item.isSold ? "Mark as Available" : "Mark as Sold",
                          systemImage: item.isSold ? "arrow.uturn.backward" : "checkmark.seal")
                }
                Button { onEdit() } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive) { onDelete() } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .contextMenu {
            Button { onToggleSold() } label: {
                Label(item.isSold ? "Mark as Available" : "Mark as Sold",
                      systemImage: item.isSold ? "arrow.uturn.backward" : "checkmark.seal")
            }
            Button { onEdit() } label: { Label("Edit", systemImage: "pencil") }
            Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }
        }
    }
}

#Preview {
    UserProfileView(vm: MarketplaceViewModel())
        .environmentObject(AppState())
        .background(Color(red: 0.07, green: 0.07, blue: 0.10))
}
