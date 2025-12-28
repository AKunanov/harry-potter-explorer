import UIKit

final class ImageCache {
    static let shared = ImageCache()

    private let cache: NSCache<NSURL, UIImage>

    private init() {
        self.cache = NSCache<NSURL, UIImage>()
        self.cache.countLimit = 300
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
