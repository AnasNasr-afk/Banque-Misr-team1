import Foundation

class TaskPresenter { 
    static func display(task: Task, index: Int? = nil) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: task.createdAt)

        var output = ""
        if let i = index {
            output += "#\(i + 1):\n"
        }
        output += """
        Assigned to: \(task.assignedTo.name)
        Title: \(task.title)
        Description: \(task.description)
        Date: \(dateString)
        Status: \(task.isDone ? "Done" : "Not Done")
        ----------------------------
        """
        print(output)
    }
}
