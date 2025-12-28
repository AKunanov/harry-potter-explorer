import Combine
import Foundation

@MainActor
final class CharacterDetailsViewModel: ObservableObject {
    @Published var details: CharacterDetails?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let service: CharacterDetailsService

    init(service: CharacterDetailsService = CharacterDetailsService()) {
        self.service = service
    }

    func load(id: String) async {
        isLoading = true
        errorMessage = nil
        details = nil
        defer { isLoading = false }
        do {
            details = try await service.fetchDetails(id: id)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
