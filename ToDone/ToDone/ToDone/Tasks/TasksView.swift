import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let isNewTask: Bool
    var task: Task?
    @State private var isEditing = false
    @State private var tempTitle: String = ""
    @State private var tempContent: String = ""
    @State private var tempPriority: Priority = .medium
    @State private var tempDueDate: Date = .now
    @State private var newComment: String = ""
    @State private var showingPastDateAlert = false
    @State private var showingNoTitleAlert = false
    
    init(task: Task? = nil) {
        self.task = task
        self.isNewTask = task == nil
        if let task = task {
            _tempTitle = State(initialValue: task.title)
            _tempContent = State(initialValue: task.content)
            _tempPriority = State(initialValue: task.priority)
            _tempDueDate = State(initialValue: task.dueDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    if isEditing || isNewTask {
                        TextField("Title", text: $tempTitle)
                            .font(.headline)
                        
                        TextField("Content", text: $tempContent, axis: .vertical)
                            .lineLimit(4...6)
                    } else {
                        Text(task?.title ?? "")
                            .font(.headline)
                        Text(task?.content ?? "")
                    }
                }
                
                if isEditing || isNewTask {
                    Section {
                        Picker("Priority", selection: $tempPriority) {
                            Text("P3 - Low").tag(Priority.low)
                            Text("P2 - Medium").tag(Priority.medium)
                            Text("P1 - High").tag(Priority.high)
                        }
                        .pickerStyle(.menu)
                        
                        DatePicker(
                            "Due Date",
                            selection: $tempDueDate,
                            in: Calendar.current.startOfDay(for: .now)...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                } else {
                    Section {
                        LabeledContent("Priority") {
                            Text(task?.priority.title ?? "")
                                .foregroundColor(priorityColor(task?.priority ?? .medium))
                        }
                        
                        LabeledContent("Due Date") {
                            Text(task?.dueDate.formatted(date: .long, time: .shortened) ?? "")
                        }
                    }
                }
                
                if !isNewTask {
                    Section("Comments") {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(task?.comments.sorted { $0.date > $1.date } ?? [], id: \.id) { comment in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(comment.text)
                                        Text(comment.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                    
                                    if comment != task?.comments.sorted(by: { $0.date > $1.date }).last {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(maxHeight: 200)  // Altura máxima para el ScrollView
                        
                        HStack {
                            TextField("Add comment", text: $newComment)
                            Button {
                                addComment()
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                            }
                            .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
            .navigationTitle(tempTitle.isEmpty ? "New Task" : tempTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if !isNewTask {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(isEditing ? "Done" : "Edit") {
                            if isEditing {
                                saveTask()
                            }
                            isEditing.toggle()
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            if tempTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                showingNoTitleAlert = true
                            } else if !isDateValid(tempDueDate) {
                                showingPastDateAlert = true
                            } else {
                                saveTask()
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .alert("Invalid Date", isPresented: $showingPastDateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The due date must be today or in the future.")
        }
        .alert("Missing Title", isPresented: $showingNoTitleAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a title for your task.")
        }
    }
    
    private func addComment() {
        guard let task = task,
              !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let comment = Comment(text: newComment)
        task.comments.append(comment)
        try? modelContext.save()
        newComment = ""
    }
    
    private func saveTask() {
        if isNewTask {
            let newTask = Task(
                title: tempTitle,
                content: tempContent,
                priority: tempPriority,
                dueDate: tempDueDate
            )
            modelContext.insert(newTask)
        } else if let existingTask = task {
            existingTask.title = tempTitle
            existingTask.content = tempContent
            existingTask.priority = tempPriority
            existingTask.dueDate = tempDueDate
        }
        try? modelContext.save()
    }
    
    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    private func isDateValid(_ date: Date) -> Bool {
        date >= Calendar.current.startOfDay(for: .now)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Task.self, configurations: config)
        let example = Task(title: "Example Task")
        return TasksView(task: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
} 