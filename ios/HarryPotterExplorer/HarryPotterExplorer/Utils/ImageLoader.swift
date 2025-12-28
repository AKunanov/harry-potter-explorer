import Combine
import Foundation
import UIKit

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false

    private var url: URL?
    private let cache: ImageCache

    init(url: URL?, cache: ImageCache = .shared) {
        self.url = url
        self.cache = cache
    }

    func update(url: URL?) {
        guard url != self.url else { return }
        self.url = url
        image = nil
    }

    func load() async {
        guard image == nil else { return }
        guard let url else {
            image = nil
            return
        }
        if let cached = cache.image(for: url) {
            image = cached
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloaded = UIImage(data: data) {
                cache.insert(downloaded, for: url)
                image = downloaded
            }
        } catch is CancellationError {
            return
        } catch {
            return
        }
    }
}
