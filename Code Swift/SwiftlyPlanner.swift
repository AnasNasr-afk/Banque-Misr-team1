import Foundation

class SwiftlyPlanner {
    private var users: [User] = []
    private var tasks: [Task] = []
    private var currentUser: User?

    func start() {
        print("Welcome to Swiftly Planner")
        registerUsers()

        var running = true
        while running {
            print("""
            
            Choose an option:
            1. Create a task
            2. View tasks grouped by day
            3. Mark task as done
            4. Exit
            
            """)
            guard let choice = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                print("Invalid input.")
                continue
            }

            switch choice {
            case "1":
                createTask()
            case "2":
                listTasksGroupedByDate()
            case "3":
                markTaskAsDone()
            case "4":
                running = false
                print("Exiting Swiftly Planner. Goodbye!")
            default:
                print("Invalid choice.")
            }
        }
    }

    private func registerUsers() {
        var count: Int = 0

        while true {
            print("How many users do you want to register?")
            if let input = readLine(), let number = Int(input.trimmingCharacters(in: .whitespaces)), number > 0 {
                count = number
                break
            } else {
                print("Invalid number. Please enter a positive integer.")
            }
        }

        for i in 1...count {
            print("Register user \(i):")

            var name: String = ""
            while true {
                print("Enter user name:")
                if let inputName = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    // Check if the input is not empty and does not consist only of digits
                    if !inputName.isEmpty && !inputName.allSatisfy({ $0.isNumber }) {
                        name = inputName
                        break
                    }
                }
                print("Invalid name. Please enter a non-empty name that is not just a number.")
            }

            var role: User.Role = .regular
            while true {
                print("Is this user an Admin? (yes/no)")
                if let roleInput = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
                    if roleInput == "yes" {
                        role = .admin
                        break
                    } else if roleInput == "no" {
                        role = .regular
                        break
                    }
                }
                print("Invalid input. Please enter 'yes' or 'no'.")
            }

            let user = User(name: name, role: role)
            users.append(user)

            // Auto-set the first admin or the first user as current user
            if currentUser == nil || (currentUser?.role != .admin && role == .admin) {
                currentUser = user
            }
        }
        
        // If no admin was registered, and there are users, make the first user admin
        if currentUser == nil && !users.isEmpty {
            print("No admin registered. Defaulting to first user as admin.")
            users[0].role = .admin
            currentUser = users[0]
        } else if currentUser?.role != .admin && !users.isEmpty {
            // If current user is not admin, but there's an admin in the list, set that admin
            if let adminUser = users.first(where: { $0.role == .admin }) {
                currentUser = adminUser
            } else if currentUser == nil && !users.isEmpty { // Fallback if still no current user
                currentUser = users[0]
            }
        }


        print("Registered \(users.count) users. Current user: \(currentUser?.name ?? "None") (\(currentUser?.role ?? .regular))")
    }

    private func createTask() {
        guard let user = currentUser else {
            print("No user is currently logged in.")
            return
        }

        guard user.role == .admin else {
            print("Only Admins can create tasks.")
            return
        }

        print("Enter task title:")
        guard let titleInput = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("Title input error.")
            return
        }

        do {
            try ValidationUtility.validate(title: titleInput) // Use the utility
        } catch {
            print("Error: Title is empty.")
            return
        }

        print("Enter task description:")
        guard let desc = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !desc.isEmpty else {
            print("Invalid description.")
            return
        }

        let assignableUsers = users.filter { $0.name != user.name }
        if assignableUsers.isEmpty {
            print("No other users available to assign the task.")
            return
        }

        print("Available users:")
        for (index, u) in assignableUsers.enumerated() {
            print("[\(index + 1)] \(u.name) (\(u.role))")
        }

        print("Enter the number of the user to assign the task to:")
        guard let input = readLine(), let userIndex = Int(input.trimmingCharacters(in: .whitespaces)),
              userIndex > 0, userIndex <= assignableUsers.count else {
            print("Invalid user.")
            return
        }

        let assignedUser = assignableUsers[userIndex - 1]
        let task = Task(title: titleInput, description: desc, assignedTo: assignedUser)
        tasks.append(task)
        print("Task created successfully and assigned to \(assignedUser.name).")
        TaskPresenter.display(task: task) 
    }

    private func listTasksGroupedByDate() {
        if tasks.isEmpty {
            print("No tasks available.")
            return
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let grouped = Dictionary(grouping: tasks) {
            formatter.string(from: $0.createdAt)
        }

        for (date, dayTasks) in grouped.sorted(by: { $0.key < $1.key }) {
            print("\nTasks for \(date):")
            for (index, task) in dayTasks.enumerated() {
                TaskPresenter.display(task: task, index: index) // Use the renamed presenter
            }
        }
    }

    private func markTaskAsDone() {
        guard let user = currentUser else {
            print("No user is currently logged in.")
            return
        }
        // Users can mark their own tasks or admins can mark any task
        let userTasks = tasks.enumerated().filter {
            $0.element.assignedTo.name == user.name || user.role == .admin
        }
        if userTasks.isEmpty {
            print("No tasks to mark as done for your user or no tasks if you are an admin.")
            return
        }
        print("Your tasks:")
        for (index, taskPair) in userTasks.enumerated() {
            print("\n[\(index + 1)]")
            TaskPresenter.display(task: taskPair.element) // Use the renamed presenter
        }

        print("Enter the task number to mark as done:")
        guard let input = readLine(), let num = Int(input.trimmingCharacters(in: .whitespaces)),
              num > 0, num <= userTasks.count else {
            print("Invalid number.")
            return
        }
        let (_, task) = userTasks[num - 1]
        task.isDone = true
        print("Task marked as done.")
        TaskPresenter.display(task: task) // Use the renamed presenter
    }
}
