import Combine
import Foundation

final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()

    private let defaults: UserDefaults
    private let storageKey = "favorite_character_ids"

    @Published private(set) var ids: Set<String>

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let stored = defaults.array(forKey: storageKey) as? [String] {
            self.ids = Set(stored)
        } else {
            self.ids = []
        }
    }

    func isFavorite(id: String) -> Bool {
        ids.contains(id)
    }

    func toggle(id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        defaults.set(Array(ids), forKey: storageKey)
    }

    func all() -> Set<String> {
        ids
    }
}
