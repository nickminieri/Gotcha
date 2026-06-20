//
//  MarketplaceViewModel.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import Foundation
import UIKit
import Combine

class MarketplaceViewModel: ObservableObject {
    @Published var items: [Item] = Item.sampleItems
    @Published var searchText: String = ""
    @Published var selectedCategory: Item.Category = .all
    @Published var selectedTab: Tab = .explore
    @Published var currentUser: User = .preview
    @Published var isPresentingCreateListing = false
    @Published var editingListing: Item?

    init() {
        #if DEBUG
        // Launch-argument hooks for deterministic screenshots / UI runs.
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-uiSeedMyListings") {
            currentUser = User.fromCampusEmail("alex.rivera@nyu.edu")
            let mine = [
                Item(title: "Desk Chair (ergonomic)", description: "Mesh back, adjustable height. Great for long study sessions.", price: 55.00, category: .furniture, condition: .good, sellerName: currentUser.name, university: currentUser.university),
                Item(title: "AirPods Pro (2nd gen)", description: "Includes case and tips. Battery health excellent.", price: 135.00, category: .electronics, condition: .likeNew, sellerName: currentUser.name, university: currentUser.university)
            ]
            items.insert(contentsOf: mine, at: 0)
            currentUser.listedCount = mine.count
        }
        if let i = args.firstIndex(of: "-uiStartTab"), i + 1 < args.count,
           let tab = Tab(rawValue: args[i + 1]) {
            selectedTab = tab
        }
        if args.contains("-uiPresentCreate") {
            isPresentingCreateListing = true
        }
        #endif
    }

    // MARK: - Tab Definition
    enum Tab: String, CaseIterable {
        case explore   = "Explore"
        case favorites = "Favorites"
        case messages  = "Messages"
        case profile   = "Profile"

        var symbols: (default: String, filled: String) {
            switch self {
            case .explore:   return ("house",            "house.fill")
            case .favorites: return ("heart",            "heart.fill")
            case .messages:  return ("bubble.left",      "bubble.left.fill")
            case .profile:   return ("person.circle",    "person.circle.fill")
            }
        }
    }

    // MARK: - Computed
    var filteredItems: [Item] {
        let byCategory = selectedCategory == .all
            ? items
            : items.filter { $0.category == selectedCategory }
        guard !searchText.isEmpty else { return byCategory }
        return byCategory.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var favoriteItems: [Item] {
        items.filter { $0.isFavorite }
    }

    /// Listings created by the signed-in user, newest first.
    var myListings: [Item] {
        items
            .filter { $0.sellerName == currentUser.name }
            .sorted { $0.postedDate > $1.postedDate }
    }

    // MARK: - Actions
    func toggleFavorite(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        items[index].isFavorite.toggle()
    }

    /// Publishes a new listing attributed to the current user and surfaces it at
    /// the top of the marketplace.
    func addListing(
        title: String,
        description: String,
        price: Double,
        category: Item.Category,
        condition: Item.Condition
    ) {
        let item = Item(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            price: price,
            category: category,
            condition: condition,
            sellerName: currentUser.name,
            university: currentUser.university
        )
        items.insert(item, at: 0)
        currentUser.listedCount += 1
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Applies edits to an existing listing in place.
    func updateListing(
        _ item: Item,
        title: String,
        description: String,
        price: Double,
        category: Item.Category,
        condition: Item.Condition
    ) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].price = price
        items[index].category = category
        items[index].condition = condition
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Removes a listing and keeps the user's listed count in sync.
    func deleteListing(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items.remove(at: index)
        if item.sellerName == currentUser.name {
            currentUser.listedCount = max(0, currentUser.listedCount - 1)
        }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    func currentState(of item: Item) -> Item {
        items.first(where: { $0.id == item.id }) ?? item
    }
}
