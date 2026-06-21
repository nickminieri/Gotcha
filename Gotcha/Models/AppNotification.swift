//
//  AppNotification.swift
//  Gotcha
//
//  A single item in the in-app activity feed (offers, messages, reviews, sales,
//  meetups, and system notices).
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct AppNotification: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case offer
        case message
        case review
        case sale
        case meetup
        case system

        var symbol: String {
            switch self {
            case .offer:   return "tag.fill"
            case .message: return "bubble.left.fill"
            case .review:  return "star.fill"
            case .sale:    return "checkmark.seal.fill"
            case .meetup:  return "mappin.circle.fill"
            case .system:  return "sparkles"
            }
        }

        /// Accent tint for the icon chip.
        var tint: Color {
            switch self {
            case .offer:   return Color(red: 0.40, green: 0.80, blue: 0.55)
            case .message: return Theme.accent
            case .review:  return Color(red: 1.00, green: 0.78, blue: 0.30)
            case .sale:    return Color(red: 0.40, green: 0.80, blue: 0.55)
            case .meetup:  return Color(red: 0.45, green: 0.70, blue: 1.00)
            case .system:  return Theme.accentSoft
            }
        }
    }

    var id = UUID()
    var kind: Kind
    var title: String
    var body: String
    var date = Date()
    var isRead = false
    /// The person who triggered this, when applicable (drives the avatar glyph).
    var actorName: String?

    /// Compact relative time like "2h", "3d", "now".
    var relativeTime: String {
        let seconds = max(0, -date.timeIntervalSinceNow)
        switch seconds {
        case ..<60:           return "now"
        case ..<3600:         return "\(Int(seconds / 60))m"
        case ..<86400:        return "\(Int(seconds / 3600))h"
        case ..<604800:       return "\(Int(seconds / 86400))d"
        default:              return "\(Int(seconds / 604800))w"
        }
    }
}
