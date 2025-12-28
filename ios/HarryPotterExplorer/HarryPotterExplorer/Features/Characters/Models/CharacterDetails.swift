import Foundation

struct CharacterDetails: Decodable {
    let id: String?
    let name: String?
    let house: String?
    let patronus: String?
    let image: String?
    let species: String?
    let gender: String?
    let dateOfBirth: String?
    let yearOfBirth: Int?
    let wizard: Bool?
    let ancestry: String?
    let eyeColour: String?
    let hairColour: String?
    let actor: String?
    let alive: Bool?
    let wand: Wand?
}

struct Wand: Decodable {
    let wood: String?
    let core: String?
    let length: Double?
}
