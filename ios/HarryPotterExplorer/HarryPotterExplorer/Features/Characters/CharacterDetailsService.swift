import Foundation

final class CharacterDetailsService {
    private let api: ApiClient

    init(api: ApiClient = ApiClient()) {
        self.api = api
    }

    func fetchDetails(id: String) async throws -> CharacterDetails {
        try await api.request(Endpoint(path: "/v1/characters/\(id)"))
    }
}
