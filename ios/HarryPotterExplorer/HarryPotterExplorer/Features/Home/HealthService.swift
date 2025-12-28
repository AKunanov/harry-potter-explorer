import Foundation

final class HealthService {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = AppConfig.apiBaseURL) {
        self.session = session
        self.baseURL = baseURL
    }

    func checkHealth() async -> Bool {
        do {
            let url = try Endpoint(path: "/health").url(baseURL: baseURL)
            let (_, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            return (200..<300).contains(httpResponse.statusCode)
        } catch {
            return false
        }
    }
}
