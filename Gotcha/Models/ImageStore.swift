//
//  ImageStore.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import UIKit

/// Stores listing photos as JPEG files in the app's Documents directory and
/// keeps a small in-memory cache. Item models only persist the filename, so the
/// JSON store in UserDefaults stays lightweight.
final class ImageStore {
    static let shared = ImageStore()

    private let cache = NSCache<NSString, UIImage>()
    private let directory: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directory = docs.appendingPathComponent("listing-images", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func url(for name: String) -> URL {
        directory.appendingPathComponent(name)
    }

    /// Writes JPEG data to disk and returns the generated filename.
    func save(_ data: Data) -> String? {
        let name = UUID().uuidString + ".jpg"
        do {
            try data.write(to: url(for: name))
            if let image = UIImage(data: data) {
                cache.setObject(image, forKey: name as NSString)
            }
            return name
        } catch {
            return nil
        }
    }

    func image(named name: String) -> UIImage? {
        if let cached = cache.object(forKey: name as NSString) { return cached }
        guard let image = UIImage(contentsOfFile: url(for: name).path) else { return nil }
        cache.setObject(image, forKey: name as NSString)
        return image
    }

    func delete(named name: String) {
        cache.removeObject(forKey: name as NSString)
        try? FileManager.default.removeItem(at: url(for: name))
    }

    /// Downscales and JPEG-compresses an image so stored photos stay small.
    static func compress(_ image: UIImage, maxDimension: CGFloat = 1200, quality: CGFloat = 0.7) -> Data? {
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: target, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
