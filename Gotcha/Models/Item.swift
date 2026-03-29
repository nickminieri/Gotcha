//
//  Item.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct Item: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var price: Double
    var category: Category
    var condition: Condition
    var sellerName: String
    var university: String
    var isFavorite: Bool
    var postedDate: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        price: Double,
        category: Category,
        condition: Condition = .good,
        sellerName: String = "Anonymous",
        university: String = "",
        isFavorite: Bool = false,
        postedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.category = category
        self.condition = condition
        self.sellerName = sellerName
        self.university = university
        self.isFavorite = isFavorite
        self.postedDate = postedDate
    }

    // MARK: - Category
    enum Category: String, CaseIterable, Identifiable {
        case all         = "All"
        case clothing    = "Clothing"
        case electronics = "Electronics"
        case furniture   = "Furniture"
        case appliances  = "Appliances"
        case books       = "Books"
        case other       = "Other"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .all:         return "square.grid.2x2.fill"
            case .clothing:    return "tshirt.fill"
            case .electronics: return "laptopcomputer"
            case .furniture:   return "sofa.fill"
            case .appliances:  return "microwave.fill"
            case .books:       return "books.vertical.fill"
            case .other:       return "tag.fill"
            }
        }

        var gradientColors: [Color] {
            switch self {
            case .all:         return [Color(red: 0.50, green: 0.32, blue: 1.00), Color(red: 0.85, green: 0.55, blue: 1.00)]
            case .clothing:    return [Color(red: 0.30, green: 0.50, blue: 1.00), Color(red: 0.55, green: 0.75, blue: 1.00)]
            case .electronics: return [Color(red: 0.00, green: 0.60, blue: 0.90), Color(red: 0.00, green: 0.88, blue: 0.80)]
            case .furniture:   return [Color(red: 0.80, green: 0.40, blue: 0.10), Color(red: 1.00, green: 0.70, blue: 0.25)]
            case .appliances:  return [Color(red: 0.15, green: 0.70, blue: 0.40), Color(red: 0.35, green: 0.95, blue: 0.55)]
            case .books:       return [Color(red: 0.90, green: 0.20, blue: 0.40), Color(red: 1.00, green: 0.50, blue: 0.55)]
            case .other:       return [Color(red: 0.45, green: 0.45, blue: 0.55), Color(red: 0.65, green: 0.65, blue: 0.75)]
            }
        }
    }

    // MARK: - Condition
    enum Condition: String, CaseIterable {
        case brandNew = "Brand New"
        case likeNew  = "Like New"
        case good     = "Good"
        case fair     = "Fair"

        var color: Color {
            switch self {
            case .brandNew: return Color(red: 0.20, green: 0.85, blue: 0.45)
            case .likeNew:  return Color(red: 0.35, green: 0.80, blue: 0.40)
            case .good:     return Color(red: 0.95, green: 0.75, blue: 0.10)
            case .fair:     return Color(red: 1.00, green: 0.55, blue: 0.15)
            }
        }
    }

    // MARK: - Sample Data
    static let sampleItems: [Item] = [
        Item(
            title: "T-Shirt with Blade Print",
            description: "Barely worn, perfect condition. Fits true to size M. Soft cotton blend.",
            price: 46.99,
            category: .clothing,
            condition: .likeNew,
            sellerName: "Jordan M.",
            university: "NYU"
        ),
        Item(
            title: "Ace High-top Sneakers",
            description: "Size 10, worn twice. No scuffs or creases. Comes with original box.",
            price: 73.99,
            category: .clothing,
            condition: .likeNew,
            sellerName: "Taylor K.",
            university: "BU"
        ),
        Item(
            title: "Le Marché Watch",
            description: "Stainless steel case, sapphire crystal glass. Minimal wear.",
            price: 119.99,
            category: .electronics,
            condition: .good,
            sellerName: "Alex P.",
            university: "MIT"
        ),
        Item(
            title: "Oversize Polo",
            description: "Vintage polo, size L/XL fits oversized. Great for layering.",
            price: 98.99,
            category: .clothing,
            condition: .good,
            sellerName: "Sam R.",
            university: "Harvard"
        ),
        Item(
            title: "MacBook Pro 13\"",
            description: "2021 M1, 16GB RAM, 512GB SSD. Includes original charger and box.",
            price: 899.99,
            category: .electronics,
            condition: .good,
            sellerName: "Chris L.",
            university: "MIT"
        ),
        Item(
            title: "Calculus Textbook",
            description: "Stewart Calculus 8th Edition. Some highlighting in chapters 1–3.",
            price: 29.99,
            category: .books,
            condition: .fair,
            sellerName: "Morgan T.",
            university: "BU"
        ),
        Item(
            title: "IKEA Desk Lamp",
            description: "White Forså series. Barely used, includes bulb.",
            price: 14.99,
            category: .furniture,
            condition: .likeNew,
            sellerName: "Riley B.",
            university: "Harvard"
        ),
        Item(
            title: "Mini Fridge",
            description: "3.2 cu ft. Perfect for dorm. Works great, very clean inside.",
            price: 65.00,
            category: .appliances,
            condition: .good,
            sellerName: "Casey W.",
            university: "NYU"
        ),
    ]
}

// MARK: - Hashable
extension Item: Hashable {
    static func == (lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
