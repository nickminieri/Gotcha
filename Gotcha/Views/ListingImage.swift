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
    let imageFilename: String?
    let category: Item.Category
    var symbolSize: CGFloat = 48

    init(item: Item, symbolSize: CGFloat = 48) {
        self.imageFilename = item.imageFilename
        self.category = item.category
        self.symbolSize = symbolSize
    }

    init(imageFilename: String?, category: Item.Category, symbolSize: CGFloat = 48) {
        self.imageFilename = imageFilename
        self.category = category
        self.symbolSize = symbolSize
    }

    var body: some View {
        if let name = imageFilename, let ui = ImageStore.shared.image(named: name) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: category.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: category.symbol)
                    .font(.system(size: symbolSize, weight: .semibold))
                    .foregroundColor(.white.opacity(0.28))
            }
        }
    }
}
