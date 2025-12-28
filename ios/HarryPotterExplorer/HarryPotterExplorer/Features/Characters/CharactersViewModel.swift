import Combine
import Foundation

@MainActor
final class CharactersViewModel: ObservableObject {
    @Published var items: [CharacterPreview] = []
    @Published var isLoading = false
    @Published var errorText: String? = nil
    @Published var query: String = ""
    @Published var isShowingFavorites: Bool = false

    private let service: CharactersService
    private var page = 1
    private let limit = 20
    private var total = 0
    private var searchTask: Task<Void, Never>?

    var canLoadMore: Bool {
        items.count < total
    }

    init(service: CharactersService = CharactersService()) {
        self.service = service
    }

    func reload() async {
        page = 1
        total = 0
        items = []
        errorText = nil
        await loadPage(reset: true)
    }

    func loadNextPageIfNeeded(currentItem: CharacterPreview) async {
        guard currentItem.id == items.last?.id else { return }
        guard canLoadMore, !isLoading else { return }
        page += 1
        await loadPage(reset: false)
    }

    func onQueryChanged(_ newValue: String) {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            if Task.isCancelled { return }
            query = newValue
            await reload()
        }
    }

    private func loadPage(reset: Bool) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await service.fetchCharacters(page: page, limit: limit, query: query)
            total = response.total
            if reset {
                items = response.items
            } else {
                items += response.items
            }
        } catch is CancellationError {
            return
        } catch {
            errorText = error.localizedDescription
        }
    }
}
