//
//  FilterSheet.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

struct FilterSheet: View {
    @ObservedObject var vm: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss

    // Local price working value; nil maxPrice means "no limit" (slider at max).
    @State private var price: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // Condition
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Condition")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            FlowRow(spacing: 8) {
                                ForEach(Item.Condition.allCases, id: \.self) { cond in
                                    let selected = vm.conditionFilter.contains(cond)
                                    Button {
                                        toggleCondition(cond)
                                    } label: {
                                        HStack(spacing: 6) {
                                            Circle().fill(cond.color).frame(width: 7, height: 7)
                                            Text(cond.rawValue)
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(selected ? .white : cond.color)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 9)
                                        .background(
                                            Capsule().fill(selected ? cond.color : cond.color.opacity(0.13))
                                        )
                                    }
                                    .buttonStyle(SpringButtonStyle())
                                }
                            }
                        }

                        // Max price
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Max Price")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(price >= vm.priceCeiling
                                     ? "Any"
                                     : String(format: "$%.0f", price))
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundColor(Color(red: 0.70, green: 0.52, blue: 1.00))
                            }
                            Slider(value: $price, in: 0...vm.priceCeiling, step: 5)
                                .tint(Color(red: 0.60, green: 0.40, blue: 1.00))
                            HStack {
                                Text("$0").font(.system(size: 12, design: .rounded))
                                Spacer()
                                Text(String(format: "$%.0f", vm.priceCeiling))
                                    .font(.system(size: 12, design: .rounded))
                            }
                            .foregroundColor(.white.opacity(0.3))
                        }

                        // Hide sold
                        Toggle(isOn: $vm.hideSold) {
                            Text("Hide sold items")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .tint(Color(red: 0.60, green: 0.40, blue: 1.00))

                        Spacer(minLength: 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        vm.clearFilters()
                        price = vm.priceCeiling
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { commit(); dismiss() }
                        .foregroundColor(Color(red: 0.70, green: 0.52, blue: 1.00))
                        .fontWeight(.semibold)
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(28)
        .onAppear { price = vm.maxPrice ?? vm.priceCeiling }
    }

    private func toggleCondition(_ cond: Item.Condition) {
        if vm.conditionFilter.contains(cond) {
            vm.conditionFilter.remove(cond)
        } else {
            vm.conditionFilter.insert(cond)
        }
    }

    private func commit() {
        vm.maxPrice = price >= vm.priceCeiling ? nil : price
    }
}

// MARK: - Simple wrapping layout for chips
struct FlowRow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
