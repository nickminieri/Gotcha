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
    @Published var items: [Item] = Item.sampleItems {
        didSet { persistItemsIfNeeded() }
    }
    @Published var searchText: String = ""
    @Published var selectedCategory: Item.Category = .all
    @Published var sortOption: SortOption = .recent
    @Published var conditionFilter: Set<Item.Condition> = []
    @Published var maxPrice: Double?
    @Published var hideSold: Bool = false
    @Published var selectedTab: Tab = .explore
    @Published var currentUser: User = .preview
    @Published var isPresentingCreateListing = false
    @Published var editingListing: Item?

    /// When false (e.g. seeded UI-test runs), changes aren't written to disk.
    private var persistenceEnabled = true
    private static let itemsKey = "gotcha.items.v1"

    init() {
        #if DEBUG
        // Launch-argument hooks for deterministic screenshots / UI runs.
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-uiResetStore") {
            UserDefaults.standard.removeObject(forKey: Self.itemsKey)
        }
        if args.contains("-uiSeedMyListings") {
            persistenceEnabled = false
            currentUser = User.fromCampusEmail("alex.rivera@nyu.edu")
            let mine = [
                Item(title: "Desk Chair (ergonomic)", description: "Mesh back, adjustable height. Great for long study sessions.", price: 55.00, category: .furniture, condition: .good, sellerName: currentUser.name, university: currentUser.university),
                Item(title: "AirPods Pro (2nd gen)", description: "Includes case and tips. Battery health excellent.", price: 135.00, category: .electronics, condition: .likeNew, sellerName: currentUser.name, university: currentUser.university)
            ]
            items.insert(contentsOf: mine, at: 0)
            currentUser.listedCount = mine.count
            // Attach rendered sample photos so image rendering is visible in runs.
            if let d = Self.debugSamplePhoto("Desk Chair", [.systemIndigo, .systemTeal]) {
                items[0].imageFilename = ImageStore.shared.save(d)
            }
            if let d = Self.debugSamplePhoto("AirPods Pro", [.black, .systemGray]) {
                items[1].imageFilename = ImageStore.shared.save(d)
            }
            items[1].isSold = true
        } else {
            loadItems()
        }
        if let i = args.firstIndex(of: "-uiAddTestListing"), i + 1 < args.count {
            addListing(title: args[i + 1], description: "Added by UI hook.", price: 42.00, category: .other, condition: .good)
        }
        if let i = args.firstIndex(of: "-uiStartTab"), i + 1 < args.count,
           let tab = Tab(rawValue: args[i + 1]) {
            selectedTab = tab
        }
        if args.contains("-uiPresentCreate") {
            isPresentingCreateListing = true
        }
        #else
        loadItems()
        #endif
    }

    // MARK: - Sorting
    enum SortOption: String, CaseIterable, Identifiable {
        case recent       = "Newest"
        case priceLowHigh = "Price: Low to High"
        case priceHighLow = "Price: High to Low"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .recent:       return "clock"
            case .priceLowHigh: return "arrow.up"
            case .priceHighLow: return "arrow.down"
            }
        }
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
        var result = selectedCategory == .all
            ? items
            : items.filter { $0.category == selectedCategory }
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        if !conditionFilter.isEmpty {
            result = result.filter { conditionFilter.contains($0.condition) }
        }
        if let maxPrice {
            result = result.filter { $0.price <= maxPrice }
        }
        if hideSold {
            result = result.filter { !$0.isSold }
        }
        return sorted(result)
    }

    /// Highest listing price, rounded up to a tidy slider ceiling.
    var priceCeiling: Double {
        let maxItem = items.map(\.price).max() ?? 1000
        return (maxItem / 50).rounded(.up) * 50
    }

    var activeFilterCount: Int {
        (conditionFilter.isEmpty ? 0 : 1) + (maxPrice == nil ? 0 : 1) + (hideSold ? 1 : 0)
    }

    func clearFilters() {
        conditionFilter = []
        maxPrice = nil
        hideSold = false
    }

    private func sorted(_ list: [Item]) -> [Item] {
        switch sortOption {
        case .recent:       return list.sorted { $0.postedDate > $1.postedDate }
        case .priceLowHigh: return list.sorted { $0.price < $1.price }
        case .priceHighLow: return list.sorted { $0.price > $1.price }
        }
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

    /// Flips a listing's sold status (owner action).
    func toggleSold(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isSold.toggle()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Publishes a new listing attributed to the current user and surfaces it at
    /// the top of the marketplace.
    func addListing(
        title: String,
        description: String,
        price: Double,
        category: Item.Category,
        condition: Item.Condition,
        imageData: Data? = nil
    ) {
        let item = Item(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            price: price,
            category: category,
            condition: condition,
            sellerName: currentUser.name,
            university: currentUser.university,
            imageFilename: imageData.flatMap { ImageStore.shared.save($0) }
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
        condition: Item.Condition,
        imageData: Data? = nil
    ) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].price = price
        items[index].category = category
        items[index].condition = condition
        // Replace the photo only when a new one was picked.
        if let imageData {
            if let old = items[index].imageFilename { ImageStore.shared.delete(named: old) }
            items[index].imageFilename = ImageStore.shared.save(imageData)
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Removes a listing and keeps the user's listed count in sync.
    func deleteListing(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if let name = items[index].imageFilename { ImageStore.shared.delete(named: name) }
        items.remove(at: index)
        if item.sellerName == currentUser.name {
            currentUser.listedCount = max(0, currentUser.listedCount - 1)
        }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    func currentState(of item: Item) -> Item {
        items.first(where: { $0.id == item.id }) ?? item
    }

    // MARK: - Persistence
    /// Loads saved listings from disk, falling back to the bundled samples on
    /// first launch or if decoding fails.
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: Self.itemsKey),
              let saved = try? JSONDecoder().decode([Item].self, from: data) else {
            return // keep the default sample items
        }
        items = saved
    }

    private func persistItemsIfNeeded() {
        guard persistenceEnabled else { return }
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: Self.itemsKey)
    }

    #if DEBUG
    /// Renders a stand-in "photo" (gradient + label) for screenshot/demo runs,
    /// so the image code path is exercised without the system photo picker.
    private static func debugSamplePhoto(_ label: String, _ colors: [UIColor]) -> Data? {
        let size = CGSize(width: 700, height: 700)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let cg = ctx.cgContext
            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: [0, 1]
            ) {
                cg.drawLinearGradient(gradient, start: .zero,
                                      end: CGPoint(x: size.width, y: size.height), options: [])
            }
            let text = "📷 \(label)" as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .heavy),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            let textSize = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (size.width - textSize.width) / 2,
                                  y: (size.height - textSize.height) / 2), withAttributes: attrs)
        }
        return image.jpegData(compressionQuality: 0.8)
    }
    #endif
}
