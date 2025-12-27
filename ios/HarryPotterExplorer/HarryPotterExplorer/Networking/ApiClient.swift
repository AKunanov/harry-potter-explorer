import Foundation

enum ApiError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
}

final class ApiClient {
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        baseURL: URL = AppConfig.apiBaseURL,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.baseURL = baseURL
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let url = try endpoint.url(baseURL: baseURL)
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ApiError.httpStatus(httpResponse.statusCode)
        }
        return try decoder.decode(T.self, from: data)
    }
}
