import Combine
import Foundation

@MainActor
final class HomeCharacterStore: ObservableObject {
    static let shared = HomeCharacterStore()

    @Published private(set) var selectedCharacterId: String?

    private let defaults: UserDefaults
    private let storageKey = "home_selected_character_id"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.selectedCharacterId = defaults.string(forKey: storageKey)
    }

    func setSelected(id: String) {
        selectedCharacterId = id
        defaults.set(id, forKey: storageKey)
    }

    func clearSelection() {
        selectedCharacterId = nil
        defaults.removeObject(forKey: storageKey)
    }
}
