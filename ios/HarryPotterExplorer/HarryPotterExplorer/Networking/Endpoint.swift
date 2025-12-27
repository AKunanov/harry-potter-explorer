import Foundation

struct Endpoint {
    let path: String
    var queryItems: [URLQueryItem]

    init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }

    func url(baseURL: URL) throws -> URL {
        guard let base = URL(string: path, relativeTo: baseURL) else {
            throw ApiError.invalidURL
        }
        if queryItems.isEmpty {
            return base
        }
        var components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw ApiError.invalidURL
        }
        return url
    }
}
