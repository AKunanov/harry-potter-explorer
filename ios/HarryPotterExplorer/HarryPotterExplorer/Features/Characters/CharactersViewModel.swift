import Foundation

@MainActor
final class CharactersViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: ApiClient

    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }
}
