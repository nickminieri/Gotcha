//
//  CreateListingView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI
import PhotosUI

// MARK: - Create Listing
struct CreateListingView: View {
    @ObservedObject var vm: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss

    /// When set, the form edits this listing instead of creating a new one.
    private let editingItem: Item?

    @State private var title: String
    @State private var priceText: String
    @State private var description: String
    @State private var category: Item.Category
    @State private var condition: Item.Condition
    @State private var photoItem: PhotosPickerItem?
    @State private var pickedImageData: Data?
    @FocusState private var focusedField: Field?

    private enum Field { case title, price, description }

    init(vm: MarketplaceViewModel, editingItem: Item? = nil) {
        self.vm = vm
        self.editingItem = editingItem
        _title = State(initialValue: editingItem?.title ?? "")
        _priceText = State(initialValue: editingItem.map { String(format: "%.2f", $0.price) } ?? "")
        _description = State(initialValue: editingItem?.description ?? "")
        _category = State(initialValue: editingItem?.category ?? .clothing)
        _condition = State(initialValue: editingItem?.condition ?? .good)
    }

    private var isEditing: Bool { editingItem != nil }

    /// The photo to show: a freshly picked one, else the listing's existing photo.
    private var previewImage: UIImage? {
        if let data = pickedImageData { return UIImage(data: data) }
        if let name = editingItem?.imageFilename { return ImageStore.shared.image(named: name) }
        return nil
    }

    /// Categories a user can actually post into (excludes the "All" filter).
    private var postableCategories: [Item.Category] {
        Item.Category.allCases.filter { $0 != .all }
    }

    private var parsedPrice: Double? {
        Double(priceText.trimmingCharacters(in: .whitespaces))
    }

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && (parsedPrice ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.10)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // Preview of how the card will look
                        previewCard
                            .padding(.top, 4)

                        // Photo
                        FieldBlock(label: "Photo") {
                            photoPicker
                        }

                        // Title
                        FieldBlock(label: "Title") {
                            StyledTextField(
                                placeholder: "What are you selling?",
                                text: $title,
                                isFocused: focusedField == .title
                            )
                            .focused($focusedField, equals: .title)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .price }
                        }

                        // Price
                        FieldBlock(label: "Price") {
                            HStack(spacing: 0) {
                                Text("$")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.45))
                                    .padding(.leading, 18)
                                StyledTextField(
                                    placeholder: "0.00",
                                    text: $priceText,
                                    isFocused: focusedField == .price,
                                    bordered: false
                                )
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .price)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(focusedField == .price ? 0.11 : 0.07))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(
                                                Color.white.opacity(focusedField == .price ? 0.22 : 0),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .animation(.easeInOut(duration: 0.2), value: focusedField)
                        }

                        // Category
                        FieldBlock(label: "Category") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(postableCategories) { cat in
                                        CategoryChip(
                                            category: cat,
                                            isSelected: category == cat
                                        ) {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                category = cat
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                        }

                        // Condition
                        FieldBlock(label: "Condition") {
                            HStack(spacing: 8) {
                                ForEach(Item.Condition.allCases, id: \.self) { cond in
                                    ConditionChip(
                                        condition: cond,
                                        isSelected: condition == cond
                                    ) {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            condition = cond
                                        }
                                    }
                                }
                            }
                        }

                        // Description
                        FieldBlock(label: "Description") {
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("Add details buyers should know...")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.white.opacity(0.22))
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 16)
                                }
                                TextEditor(text: $description)
                                    .focused($focusedField, equals: .description)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 9)
                                    .frame(minHeight: 110, alignment: .topLeading)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(focusedField == .description ? 0.11 : 0.07))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(
                                                Color.white.opacity(focusedField == .description ? 0.22 : 0),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .animation(.easeInOut(duration: 0.2), value: focusedField)
                        }

                        publishButton
                            .padding(.top, 4)
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(isEditing ? "Edit Listing" : "New Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.6))
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .toolbarBackground(Color(red: 0.07, green: 0.07, blue: 0.10), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Photo Picker
    private var photoPicker: some View {
        PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
            ZStack {
                if let image = previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: category.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(0.25)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 30, weight: .semibold))
                        Text("Add a photo")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .bottomTrailing) {
                if previewImage != nil {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white, Color(red: 0.50, green: 0.32, blue: 1.00))
                        .padding(10)
                }
            }
        }
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        pickedImageData = ImageStore.compress(image)
                    }
                }
            }
        }
    }

    // MARK: - Live Preview Card
    private var previewCard: some View {
        HStack(spacing: 14) {
            ZStack {
                if let image = previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: category.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: category.symbol)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(width: 76, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title.isEmpty ? "Your listing title" : title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(title.isEmpty ? .white.opacity(0.3) : .white)
                    .lineLimit(1)
                Text(String(format: "$%.2f", parsedPrice ?? 0))
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                HStack(spacing: 4) {
                    Circle().fill(condition.color).frame(width: 6, height: 6)
                    Text(condition.rawValue)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(condition.color)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }

    // MARK: - Publish Button
    private var publishButton: some View {
        Button {
            guard let price = parsedPrice, canPublish else { return }
            if let editingItem {
                vm.updateListing(
                    editingItem,
                    title: title,
                    description: description,
                    price: price,
                    category: category,
                    condition: condition,
                    imageData: pickedImageData
                )
            } else {
                vm.addListing(
                    title: title,
                    description: description,
                    price: price,
                    category: category,
                    condition: condition,
                    imageData: pickedImageData
                )
            }
            dismiss()
        } label: {
            Text(isEditing ? "Save Changes" : "Publish Listing")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                 Color(red: 0.85, green: 0.55, blue: 1.00)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .opacity(canPublish ? 1.0 : 0.4)
                .animation(.easeInOut(duration: 0.2), value: canPublish)
        }
        .disabled(!canPublish)
    }
}

// MARK: - Field Block (label + content)
private struct FieldBlock<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .padding(.leading, 4)
            content
        }
    }
}

// MARK: - Styled Text Field
private struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    let isFocused: Bool
    var bordered: Bool = true

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder).foregroundColor(.white.opacity(0.22))
        )
        .foregroundColor(.white)
        .font(.system(size: 16, design: .rounded))
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            Group {
                if bordered {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(isFocused ? 0.11 : 0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(isFocused ? 0.22 : 0), lineWidth: 1)
                        )
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Condition Chip
private struct ConditionChip: View {
    let condition: Item.Condition
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(condition.rawValue)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : condition.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? condition.color : condition.color.opacity(0.13))
                )
        }
        .buttonStyle(SpringButtonStyle())
    }
}

#Preview {
    CreateListingView(vm: MarketplaceViewModel())
}
