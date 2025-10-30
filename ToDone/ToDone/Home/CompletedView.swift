import SwiftUI
import SwiftData

enum SortOption {
    case date
    case priority
}

struct CompletedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    @State private var showingSettings = false
    @State private var selectedTask: Task?
    @State private var searchText = ""
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var sortOption: SortOption = .date
    
    var body: some View {
        NavigationStack {
            Group {
                if completedTasks.isEmpty {
                    EmptyStateView()
                } else {
                    TaskListView(
                        tasks: completedTasks,
                        selectedTask: $selectedTask
                    )
                }
            }
            .navigationTitle("Completed")
            .toolbar {
                ToolbarItems(
                    showingSettings: $showingSettings,
                    sortOption: $sortOption
                )
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .preferredColorScheme(appTheme.colorScheme)
        }
        .sheet(item: $selectedTask) { task in
            TasksView(task: task)
        }
        .searchable(text: $searchText, prompt: "Search completed tasks")
    }
    
    // MARK: - Computed Properties
    private var completedTasks: [Task] {
        sortTasks(filterTasks(tasks))
    }
    
    // MARK: - Helper Functions
    private func filterTasks(_ tasks: [Task]) -> [Task] {
        let completed = tasks.filter { $0.isCompleted }
        
        if searchText.isEmpty {
            return completed
        }
        
        return completed.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func sortTasks(_ tasks: [Task]) -> [Task] {
        tasks.sorted { first, second in
            switch sortOption {
            case .date:
                return first.dueDate < second.dueDate
            case .priority:
                return first.priority.rawValue > second.priority.rawValue
            }
        }
    }
}

// MARK: - Supporting Views
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            ContentUnavailableView {
                Label("No Completed Tasks", systemImage: "checklist")
            } description: {
                Text("No tasks have been completed yet.")
            }
            .offset(y: -40)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

private struct TaskListView: View {
    let tasks: [Task]
    @Binding var selectedTask: Task?
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskRowView(task: task)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTask = task
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            withAnimation {
                                task.isCompleted = false
                            }
                        } label: {
                            Label("Uncomplete", systemImage: "arrow.uturn.backward")
                        }
                        .tint(.blue)
                    }
            }
        }
    }
}

private struct ToolbarItems: ToolbarContent {
    @Binding var showingSettings: Bool
    @Binding var sortOption: SortOption
    
    var body: some ToolbarContent {
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
    }
}
