import Foundation
import SwiftData

enum Priority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    
    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

@Model
final class Task {
    var title: String
    var content: String
    var comments: [Comment]
    var priority: Priority
    var dueDate: Date
    var createdAt: Date
    var isCompleted: Bool
    
    init(
        title: String = "",
        content: String = "",
        comments: [Comment] = [],
        priority: Priority = .medium,
        dueDate: Date = .now,
        createdAt: Date = .now,
        isCompleted: Bool = false
    ) {
        self.title = title
        self.content = content
        self.comments = comments
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
}

@Model
final class Comment {
    var text: String
    var date: Date
    
    init(text: String, date: Date = .now) {
        self.text = text
        self.date = date
    }
} 