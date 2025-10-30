import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    @State private var showingSettings = false
    @State private var selectedTask: Task?
    @State private var showingNewTask = false
    @State private var searchText = ""
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var sortOption: SortOption = .date
    
    enum SortOption {
        case date
        case priority
        
        var title: String {
            switch self {
            case .date:
                return "By Date"
            case .priority:
                return "By Priority"
            }
        }
        
        var icon: String {
            switch self {
            case .date:
                return "calendar.day.timeline.left"
            case .priority:
                return "rectangle.on.rectangle.angled"
            }
        }
    }
    
    private var activeTasks: [Task] {
        let filtered = tasks.filter { !$0.isCompleted }
        let searchFiltered = searchText.isEmpty ? filtered : filtered.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
        
        return searchFiltered.sorted { first, second in
            switch sortOption {
            case .date:
                return first.dueDate < second.dueDate
            case .priority:
                return first.priority.rawValue > second.priority.rawValue
            }
        }
    }
    
    private var searchSuggestions: [String] {
        if searchText.isEmpty {
            return Array(Set(tasks.map { $0.title }))
                .prefix(3)
                .sorted()
        }
        return []
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        
                        ContentUnavailableView {
                            Label("No Tasks", systemImage: "checklist")
                        } description: {
                            Text("Start by creating your first task")
                        } actions: {
                            Button {
                                showingNewTask.toggle()
                            } label: {
                                Label("New Task", systemImage: "plus")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .offset(y: -40)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground))
                } else {
                    Group {
                        if !searchText.isEmpty && activeTasks.isEmpty {
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                
                                ContentUnavailableView.search(text: searchText)
                                    .offset(y: -40)
                                
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemGroupedBackground))
                        } else {
                            List {
                                ForEach(activeTasks) { task in
                                    TaskRowView(task: task)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedTask = task
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                modelContext.delete(task)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            .tint(Color.red)
                                            
                                            Button {
                                                task.isCompleted.toggle()
                                            } label: {
                                                Label("Complete", systemImage: "checkmark.circle")
                                            }
                                            .tint(Color.green)
                                        }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search tasks")
                    .searchSuggestions {
                        if searchText.isEmpty {
                            ForEach(searchSuggestions, id: \.self) { suggestion in
                                Text(suggestion)
                                    .searchCompletion(suggestion)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            sortOption = .date
                        } label: {
                            Label("By Date", systemImage: "calendar.day.timeline.left")
                                .symbolRenderingMode(.hierarchical)
                        }
                        
                        Button {
                            sortOption = .priority
                        } label: {
                            Label("By Priority", systemImage: "rectangle.on.rectangle.angled")
                                .symbolRenderingMode(.hierarchical)
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewTask.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .preferredColorScheme(appTheme.colorScheme)
        }
        .sheet(item: $selectedTask) { task in
            TasksView(task: task)
        }
        .sheet(isPresented: $showingNewTask) {
            NewTaskView(isPresented: $showingNewTask)
        }
    }
}

struct NewTaskView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            TasksView()
        }
    }
}

// Vista auxiliar para mostrar cada tarea en la lista
struct TaskRowView: View {
    let task: Task
    
    private var isOverdue: Bool {
        task.dueDate < .now
    }
    
    private var isUpcoming: Bool {
        guard !isOverdue else { return false }
        let timeUntilDue = task.dueDate.timeIntervalSince(.now)
        return timeUntilDue <= 24 * 3600 // 24 horas en segundos
    }
    
    private var dateText: String {
        let formattedDate = task.dueDate.formatted(date: .abbreviated, time: .omitted)
        if isOverdue {
            let days = Calendar.current.dateComponents([.day], from: task.dueDate, to: .now).day ?? 0
            return "\(formattedDate)\n\(days) day\(days == 1 ? "" : "s") overdue"
        }
        return formattedDate
    }
    
    private var dateColor: Color {
        if isOverdue {
            return .red
        } else if isUpcoming {
            return .orange // Mismo color que P2
        } else {
            return .secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.headline)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
            
            HStack {
                Label(task.priority.title, systemImage: "flag.fill")
                    .foregroundColor(priorityColor(task.priority))
                    .labelStyle(CompactLabelStyle())
                Spacer()
                Text(dateText)
                    .font(.caption)
                    .foregroundColor(dateColor)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.vertical, 4)
        .opacity(task.isCompleted ? 0.8 : 1.0)
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
}

struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
            configuration.title
        }
    }
}

#Preview {
    HomeView()
} 
