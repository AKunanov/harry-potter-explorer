import Foundation

struct CharactersPage: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let items: [CharacterPreview]
}
