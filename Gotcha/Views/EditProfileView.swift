//
//  EditProfileView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var vm: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var university: String
    @State private var photoItem: PhotosPickerItem?
    @State private var pickedImageData: Data?

    init(vm: MarketplaceViewModel) {
        self.vm = vm
        _name = State(initialValue: vm.currentUser.name)
        _university = State(initialValue: vm.currentUser.university)
    }

    private var avatarImage: UIImage? {
        if let data = pickedImageData { return UIImage(data: data) }
        if let name = vm.currentUser.avatarFilename { return ImageStore.shared.image(named: name) }
        return nil
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.10).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        // Avatar picker
                        PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                            ZStack(alignment: .bottomTrailing) {
                                ZStack {
                                    if let image = avatarImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        LinearGradient(
                                            colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                                     Color(red: 0.85, green: 0.55, blue: 1.00)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                        Text(String(name.prefix(1)))
                                            .font(.system(size: 40, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())

                                Image(systemName: "camera.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color(red: 0.60, green: 0.40, blue: 1.00))
                                    .clipShape(Circle())
                                    .overlay(Circle().strokeBorder(Color(red: 0.07, green: 0.07, blue: 0.10), lineWidth: 3))
                            }
                        }
                        .padding(.top, 12)

                        // Fields
                        VStack(spacing: 14) {
                            ProfileField(label: "Name", placeholder: "Your name", text: $name)
                            ProfileField(label: "University", placeholder: "e.g. NYU", text: $university)
                        }

                        Spacer(minLength: 8)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.6))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.updateProfile(name: name, university: university, avatarData: pickedImageData)
                        dismiss()
                    }
                    .foregroundColor(canSave ? Color(red: 0.70, green: 0.52, blue: 1.00) : .white.opacity(0.3))
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .toolbarBackground(Color(red: 0.07, green: 0.07, blue: 0.10), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(28)
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { pickedImageData = ImageStore.compress(image, maxDimension: 600) }
                }
            }
        }
    }
}

// MARK: - Profile Field
private struct ProfileField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .padding(.leading, 4)
            TextField("", text: $text,
                      prompt: Text(placeholder).foregroundColor(.white.opacity(0.22)))
                .foregroundColor(.white)
                .font(.system(size: 16, design: .rounded))
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                )
        }
    }
}

#Preview {
    EditProfileView(vm: MarketplaceViewModel())
}
