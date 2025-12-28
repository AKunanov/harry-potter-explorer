import Foundation

struct CharacterStoryGenerator {
    static func story(for details: CharacterDetails) -> String {
        let seed = clean(details.id) ?? clean(details.name) ?? "unknown"
        let name = clean(details.name) ?? "This figure"

        let opening = pick(from: openingPhrases(for: name), seed: seed + ":opening")

        let traitSentence = pick(
            from: traitPhrases(for: details, name: name),
            fallback: "Their path is shaped by choices more than records.",
            seed: seed + ":trait"
        )

        let detailSentence = pick(
            from: detailPhrases(for: details),
            fallback: "Some parts of their record remain unwritten.",
            seed: seed + ":detail"
        )

        let closing = pick(from: closingPhrases(), seed: seed + ":closing")

        return [opening, traitSentence, detailSentence, closing]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func openingPhrases(for name: String) -> [String] {
        [
            "Within Hogwarts, \(name) stands as a quiet legend.",
            "Whispers around the castle still mention \(name).",
            "Every house keeps its own stories, and \(name) is one of them.",
            "Some tales begin in the Great Hall, and \(name) is among them."
        ]
    }

    private static func traitPhrases(for details: CharacterDetails, name: String) -> [String] {
        var phrases: [String] = []
        if let house = clean(details.house) {
            phrases.append("Aligned with \(house), \(name) carries that house's mark.")
        }
        if let patronus = clean(details.patronus) {
            phrases.append("A patronus shaped as \(patronus) hints at what \(name) protects.")
        }
        if let ancestry = clean(details.ancestry) {
            phrases.append("Their ancestry is recorded as \(ancestry).")
        }
        if let wizardStatus = wizardStatus(details.wizard) {
            phrases.append("\(name) is known as a \(wizardStatus), moving between ordinary and magical worlds.")
        }
        if let birth = birthText(date: details.dateOfBirth, year: details.yearOfBirth) {
            phrases.append("Born \(birth), their era still colors the rumors.")
        }
        return phrases
    }

    private static func detailPhrases(for details: CharacterDetails) -> [String] {
        var phrases: [String] = []
        if let wand = wandText(details.wand) {
            phrases.append("Their wand is \(wand).")
        }
        if let actor = clean(details.actor) {
            phrases.append("On screen, they are portrayed by \(actor).")
        }
        if let aliveStatus = aliveStatus(details.alive) {
            phrases.append("By the latest records, they are \(aliveStatus).")
        }
        return phrases
    }

    private static func closingPhrases() -> [String] {
        [
            "The rest is a story told in quiet corridors.",
            "Their legacy lingers long after the last spell.",
            "The tale ends, but the echo remains.",
            "Their story stays stitched into Hogwarts lore."
        ]
    }

    private static func pick(from phrases: [String], seed: String) -> String {
        pick(from: phrases, fallback: "", seed: seed)
    }

    private static func pick(from phrases: [String], fallback: String, seed: String) -> String {
        guard !phrases.isEmpty else { return fallback }
        let index = stableIndex(seed: seed, modulo: phrases.count)
        return phrases[index]
    }

    private static func wizardStatus(_ value: Bool?) -> String? {
        guard let value else { return nil }
        return value ? "wizard" : "muggle"
    }

    private static func aliveStatus(_ value: Bool?) -> String? {
        guard let value else { return nil }
        return value ? "alive" : "deceased"
    }

    private static func birthText(date: String?, year: Int?) -> String? {
        let dateValue = clean(date)
        let yearValue = year.map { String($0) }
        switch (dateValue, yearValue) {
        case (nil, nil):
            return nil
        case let (date?, year?):
            return "\(date) (\(year))"
        case let (date?, nil):
            return date
        case let (nil, year?):
            return year
        }
    }

    private static func wandText(_ wand: Wand?) -> String? {
        let wood = clean(wand?.wood)
        let core = clean(wand?.core)
        let length = wandLengthText(wand?.length)
        let parts = [wood, core, length].compactMap { $0 }
        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: " / ")
    }

    private static func wandLengthText(_ value: Double?) -> String? {
        guard let value else { return nil }
        let intValue = Int(value)
        if value == Double(intValue) {
            return String(intValue)
        }
        return String(value)
    }

    private static func clean(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func stableIndex(seed: String, modulo: Int) -> Int {
        guard modulo > 0 else { return 0 }
        let hash = fnv1a64(seed)
        return Int(hash % UInt64(modulo))
    }

    private static func fnv1a64(_ value: String) -> UInt64 {
        var hash: UInt64 = 14695981039346656037
        let prime: UInt64 = 1099511628211
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= prime
        }
        return hash
    }
}
