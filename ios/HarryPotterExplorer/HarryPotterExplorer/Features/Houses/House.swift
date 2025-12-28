import Foundation

struct House: Identifiable, Decodable {
    let id: String
    let name: String
    let colors: [String]
    let animal: String
    let founder: String
    let description: String
}
