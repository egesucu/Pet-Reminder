import Foundation

/// Value-based matching keeps accents, casing and whitespace consistent.
enum PetSearch {
    static func matches(name: String, breed: String?, query: String) -> Bool {
        let terms = query.split(whereSeparator: { $0.isWhitespace })
        let fields = [name, breed ?? ""]
        return terms.allSatisfy { term in
            fields.contains { $0.range(of: String(term), options: [.caseInsensitive, .diacriticInsensitive]) != nil }
        }
    }
}
