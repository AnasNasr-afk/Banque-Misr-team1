import Foundation

class Task {
    let title: String
    let description: String
    let assignedTo: User
    let createdAt: Date
    var isDone: Bool

    init(title: String, description: String, assignedTo: User, createdAt: Date = Date()) {
        self.title = title
        self.description = description
        self.assignedTo = assignedTo
        self.createdAt = createdAt
        self.isDone = false
    }
}
