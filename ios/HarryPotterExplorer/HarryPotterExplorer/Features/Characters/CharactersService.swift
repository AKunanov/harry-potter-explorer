import Foundation

final class CharactersService {
    private let api: ApiClient

    init(api: ApiClient = ApiClient()) {
        self.api = api
    }

    func fetchCharacters(page: Int, limit: Int, query: String) async throws -> CharactersPage {
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        let endpoint = Endpoint(path: "/v1/characters", queryItems: queryItems)
        return try await api.request(endpoint)
    }
}
