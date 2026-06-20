//
//  ListingImage.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

/// Renders a listing's photo when one exists, otherwise the category gradient
/// with its symbol. Callers set the frame and clip shape.
struct ListingImage: View {
    let item: Item
    var symbolSize: CGFloat = 48

    var body: some View {
        if let name = item.imageFilename, let ui = ImageStore.shared.image(named: name) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: item.category.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: item.category.symbol)
                    .font(.system(size: symbolSize, weight: .semibold))
                    .foregroundColor(.white.opacity(0.28))
            }
        }
    }
}
