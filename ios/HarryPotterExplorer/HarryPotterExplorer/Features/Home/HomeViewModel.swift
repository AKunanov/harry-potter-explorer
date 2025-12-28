import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var character: CharacterDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let store: HomeCharacterStore
    private let charactersService: CharactersService
    private let detailsService: CharacterDetailsService

    init(
        store: HomeCharacterStore = .shared,
        charactersService: CharactersService = CharactersService(),
        detailsService: CharacterDetailsService = CharacterDetailsService()
    ) {
        self.store = store
        self.charactersService = charactersService
        self.detailsService = detailsService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            guard let id = try await resolveCharacterId() else {
                errorMessage = "Unable to load character."
                return
            }
            character = try await detailsService.fetchDetails(id: id)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reload() async {
        await load()
    }

    func onSelectedIdChanged() async {
        await load()
    }

    private func resolveCharacterId() async throws -> String? {
        if let selected = store.selectedCharacterId, !selected.isEmpty {
            return selected
        }
        let page = try await charactersService.fetchCharacters(page: 1, limit: 1, query: "")
        return page.items.first?.id
    }
}
