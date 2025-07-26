import Foundation

enum TaskError: Error {
    case invalidTitle
}

func validate(title: String) throws {
    if title.trimmingCharacters(in: .whitespaces).isEmpty {
        throw TaskError.invalidTitle
    }
}

