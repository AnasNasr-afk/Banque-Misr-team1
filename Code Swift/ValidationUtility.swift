import Foundation

struct ValidationUtility {
    static func validate(title: String) throws {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            throw TaskError.invalidTitle
        }
    }
}
