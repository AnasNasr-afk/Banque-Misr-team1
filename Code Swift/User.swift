import Foundation

class User {
    enum Role {
        case admin
        case regular
    }

    var name: String
    var role: Role

    init(name: String, role: Role) {
        self.name = name
        self.role = role
    }
}
