//
//  YQSUIWebImage.swift
//  Project
//
//  Created by yumumu on 2026/1/23.
//  Copyright © 2026 Thread0. All rights reserved.
//


import SwiftUI
import UIKit
import CryptoKit

/// A lightweight SwiftUI web image view with placeholder, error image and custom headers support (including Referer).
/// Usage:
/// YQSUIWebImage(url: url, placeholder: Image(systemName: "photo"), errorImage: Image(systemName: "exclamationmark.triangle"), headers: ["Referer": "https://www.example.com"]) {
///     // image modifiers
/// }
public struct YQSUIWebImage<Content: View>: View {
    @StateObject private var loader: ImageLoader
    private let content: (Image) -> Content
    private let placeholder: Content
    private let errorView: Content
    private let contentMode: ContentMode

    /// Create a web image view.
    /// - Parameters:
    ///   - url: remote image URL
    ///   - placeholder: a SwiftUI Image used as placeholder (optional)
    ///   - errorImage: a SwiftUI Image used when loading fails (optional)
    ///   - headers: optional headers to set on the request. If you want a referer header, set `headers["Referer"] = "https://www.example.com"`.
    ///   - contentMode: .fill or .fit
    ///   - cacheConfiguration: adjust memory/disk cache capacities (defaults to 50MB/200MB)
    ///   - content: closure to apply extra modifiers to the loaded Image
    public init(url: URL?,
                placeholder: Image? = nil,
                errorImage: Image? = nil,
                headers: [String: String]? = nil,
                contentMode: ContentMode = .fill,
                cacheConfiguration: YQSUIWebImageCacheConfiguration = .default,
                @ViewBuilder content: @escaping (Image) -> Content) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url, headers: headers, cacheConfig: cacheConfiguration))
        self.content = content
        self.placeholder = content(placeholder ?? Image(systemName: "photo"))
        self.errorView = content(errorImage ?? Image(systemName: "exclamationmark.triangle"))
        self.contentMode = contentMode
    }

    /// Convenience when you just want the raw Image with default modifiers.
    public init(url: URL?,
                placeholder: Image? = nil,
                errorImage: Image? = nil,
                headers: [String: String]? = nil,
                contentMode: ContentMode = .fill,
                cacheConfiguration: YQSUIWebImageCacheConfiguration = .default) where Content == Image {
        _loader = StateObject(wrappedValue: ImageLoader(url: url, headers: headers, cacheConfig: cacheConfiguration))
        self.content = { $0 }
        self.placeholder = placeholder ?? Image(systemName: "photo")
        self.errorView = errorImage ?? Image(systemName: "exclamationmark.triangle")
        self.contentMode = contentMode
    }

    public var body: some View {
        Group {
            if let ui = loader.image {
                let baseImage = Image(uiImage: ui).resizable()
                let rendered = content(baseImage)
                if contentMode == .fill {
                    rendered
                        .scaledToFill()
                        .clipped()
                } else {
                    rendered
                        .scaledToFit()
                        .clipped()
                }
            } else if loader.isLoading {
                placeholder
                    .scaledToFit()
                    .clipped()
            } else {
                errorView
                    .scaledToFit()
                    .clipped()
            }
        }
        .onAppear { loader.loadIfNeeded() }
        .onDisappear { loader.cancel() }
    }
}

public struct YQSUIWebImageCacheConfiguration: Equatable {
    public let memoryCapacity: Int
    public let diskCapacity: Int
    
    public static let `default` = YQSUIWebImageCacheConfiguration(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024)
    
    // memoryOnly: set diskCapacity to 0
    public static let memoryOnly = YQSUIWebImageCacheConfiguration(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 0)
    // diskOnly: set memoryCapacity to 0
    public static let diskOnly = YQSUIWebImageCacheConfiguration(memoryCapacity: 0, diskCapacity: 200 * 1024 * 1024)

    public init(memoryCapacity: Int, diskCapacity: Int) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
    }
}

// MARK: - ImageLoader

private final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading: Bool = false

    private static let memoryCache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.totalCostLimit = YQSUIWebImageCacheConfiguration.default.memoryCapacity
        return cache
    }()
    private static let diskCache = DiskImageCache(maxSize: YQSUIWebImageCacheConfiguration.default.diskCapacity)
    private static var currentConfig = YQSUIWebImageCacheConfiguration.default
    private static let cacheLock = NSLock()

    private var dataTask: URLSessionDataTask?
    private let url: URL?
    private let headers: [String: String]
    private let cacheConfig: YQSUIWebImageCacheConfiguration

    init(url: URL?, headers: [String: String]?, cacheConfig: YQSUIWebImageCacheConfiguration) {
        self.url = url
        var defaultHeaders: [String: String] = ["Referer": "https://www.example.com"]
        if let h = headers {
            for (k, v) in h { defaultHeaders[k] = v }
        }
        self.headers = defaultHeaders
        self.cacheConfig = cacheConfig
        ImageLoader.configureCachesIfNeeded(cacheConfig)
    }

    deinit {
        cancel()
    }

    func loadIfNeeded() {
        guard image == nil, !isLoading else { return }
        guard let url = url else { return }

        if let cached = ImageLoader.memoryCache.object(forKey: url as NSURL) {
            image = cached
            return
        }

        isLoading = true

        if cacheConfig.diskCapacity > 0 {
            ImageLoader.diskCache.image(for: url) { [weak self] diskImage in
                guard let self = self else { return }
                if let diskImage = diskImage {
                    self.cache(image: diskImage, for: url)
                    self.image = diskImage
                    self.isLoading = false
                } else {
                    self.fetchRemoteImage(for: url)
                }
            }
        } else {
            fetchRemoteImage(for: url)
        }
    }

    private func fetchRemoteImage(for url: URL) {
        var request = URLRequest(url: url)
        for (k, v) in headers {
            request.setValue(v, forHTTPHeaderField: k)
        }

        dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, resp, err in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                guard let data = data, let ui = UIImage(data: data) else {
                    self.image = nil
                    return
                }

                self.cache(image: ui, for: url)
                self.image = ui
            }
        }
        dataTask?.resume()
    }

    private func cache(image: UIImage, for url: URL) {
        let cost = image.yqs_memoryCost
        ImageLoader.memoryCache.setObject(image, forKey: url as NSURL, cost: cost)
        if cacheConfig.diskCapacity > 0 {
            ImageLoader.diskCache.store(image, for: url)
        }
    }

    func cancel() {
        dataTask?.cancel()
        dataTask = nil
        isLoading = false
    }

    private static func configureCachesIfNeeded(_ config: YQSUIWebImageCacheConfiguration) {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        guard currentConfig != config else { return }
        memoryCache.totalCostLimit = config.memoryCapacity
        diskCache.update(maxSize: config.diskCapacity)
        currentConfig = config
    }
}

private final class DiskImageCache {
    private let ioQueue = DispatchQueue(label: "com.yqsui.webimage.diskcache", qos: .utility)
    private var maxSize: Int
    private let directoryURL: URL

    init(maxSize: Int) {
        self.maxSize = maxSize
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.directoryURL = caches.appendingPathComponent("YQSUIWebImage", isDirectory: true)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        enforceLimitIfNeeded()
    }

    func update(maxSize: Int) {
        ioQueue.async {
            self.maxSize = maxSize
            if maxSize == 0 {
                self.clearAll()
            } else {
                self.enforceLimitIfNeeded()
            }
        }
    }

    func store(_ image: UIImage, for url: URL) {
        guard maxSize > 0 else { return }
        guard let data = image.pngData() ?? image.jpegData(compressionQuality: 0.9) else { return }
        let fileURL = self.fileURL(for: url)
        ioQueue.async {
            do {
                try data.write(to: fileURL, options: .atomic)
                self.touch(fileURL)
                self.enforceLimitIfNeeded()
            } catch {
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
    }

    func image(for url: URL, completion: @escaping (UIImage?) -> Void) {
        guard maxSize > 0 else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        let fileURL = self.fileURL(for: url)
        ioQueue.async {
            guard let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.touch(fileURL)
            DispatchQueue.main.async { completion(image) }
        }
    }

    private func enforceLimitIfNeeded() {
        guard maxSize > 0 else { return }
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey], options: .skipsHiddenFiles) else { return }

        var total = 0
        var metadata: [(url: URL, size: Int, date: Date)] = []
        for file in files {
            let resource = try? file.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            let size = resource?.fileSize ?? 0
            total += size
            let date = resource?.contentModificationDate ?? .distantPast
            metadata.append((file, size, date))
        }

        guard total > maxSize else { return }
        let sorted = metadata.sorted { $0.date < $1.date }
        for item in sorted {
            try? fm.removeItem(at: item.url)
            total -= item.size
            if total <= maxSize { break }
        }
    }

    private func clearAll() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else { return }
        for file in files {
            try? fm.removeItem(at: file)
        }
    }

    private func fileURL(for url: URL) -> URL {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let name = digest.compactMap { String(format: "%02x", $0) }.joined()
        return directoryURL.appendingPathComponent(name)
    }

    private func touch(_ url: URL) {
        try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
    }
}

private extension UIImage {
    var yqs_memoryCost: Int {
        let pixels = Int(size.width * size.height * max(1, scale * scale))
        return pixels * 4
    }
}

// MARK: - Previews

#if DEBUG
struct YQSUIWebImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            YQSUIWebImage(url: URL(string: "https://picsum.photos/200/200"), placeholder: Image(systemName: "photo"), errorImage: Image(systemName: "exclamationmark.triangle"),contentMode: .fit) { img in
                img
            }
            .frame(width: 160, height: 160)
            .background(Color.gray)
            .cornerRadius(8)

            YQSUIWebImage(url: nil, placeholder: Image(systemName: "photo"), errorImage: Image(systemName: "exclamationmark.triangle")) { img in
                img
            }
            .frame(width: 160, height: 160)
            .background(Color.gray)
            .cornerRadius(8)
            
            YQSUIWebImage(url: URL(string: "https://picsum.photos/200/301"), placeholder: Image(systemName: "photo"), errorImage: Image(systemName: "exclamationmark.triangle"),contentMode: .fill) { img in
                img
            }
            .frame(width: 160, height: 160)
            .background(Color.gray)
            .cornerRadius(8)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
