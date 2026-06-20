//
//  Theme.swift
//  Gotcha
//
//  Central design system: colors, gradients, and surface styles so the app
//  reads as one cohesive, premium product.
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

enum Theme {
    // MARK: - Surfaces (deep, slightly cool near-black with layered elevation)
    static let bg        = Color(red: 0.055, green: 0.055, blue: 0.075)
    static let bgRaised  = Color(red: 0.085, green: 0.085, blue: 0.11)
    static let card      = Color(red: 0.108, green: 0.108, blue: 0.138)
    static let elevated  = Color(red: 0.145, green: 0.145, blue: 0.180)

    // MARK: - Accent
    static let accent      = Color(red: 0.56, green: 0.42, blue: 1.00)
    static let accentSoft  = Color(red: 0.70, green: 0.58, blue: 1.00)
    static let accentGradient = LinearGradient(
        colors: [Color(red: 0.50, green: 0.34, blue: 1.00), Color(red: 0.78, green: 0.50, blue: 1.00)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // MARK: - Text
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.56)
    static let textTertiary  = Color.white.opacity(0.34)

    // MARK: - Hairlines / strokes
    static let hairline = Color.white.opacity(0.08)
    static let stroke   = Color.white.opacity(0.10)

    // MARK: - Status
    static let sold = Color(red: 0.95, green: 0.32, blue: 0.40)

    static let radius: CGFloat = 20
}

// MARK: - Reusable card surface
extension View {
    /// Standard elevated card surface: rounded, subtly bordered, soft shadow.
    func cardSurface(cornerRadius: CGFloat = Theme.radius, fill: Color = Theme.card) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
    }
}
