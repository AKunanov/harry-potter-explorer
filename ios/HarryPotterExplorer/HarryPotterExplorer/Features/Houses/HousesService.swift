import Foundation

final class HousesService {
    private let api: ApiClient

    init(api: ApiClient = ApiClient()) {
        self.api = api
    }

    func fetchHouses() async throws -> [House] {
        try await api.request(Endpoint(path: "/v1/houses"))
    }
}
