import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @State private var showingSettings = false
    @Query private var tasks: [Task]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        NavigationView {
            mainContent
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 300 : 400), spacing: 20)
                    ],
                    spacing: 20
                ) {
                    statisticsSection
                    weeklyProgressSection
                }
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private var headerSection: some View {
        Text("Track your task progress and completion patterns over time.")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var statisticsSection: some View {
        ChartCard(title: "Task Overview") {
            Chart {
                ForEach(taskStatistics, id: \.category) { data in
                    BarMark(
                        x: .value("Category", data.category),
                        y: .value("Count", data.count)
                    )
                    .foregroundStyle(by: .value("Category", data.category))
                    .annotation(position: .top) {
                        Text("\(data.count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartLegend(position: .bottom)
        }
    }
    
    private var weeklyProgressSection: some View {
        ChartCard(title: "Weekly Progress") {
            Chart {
                ForEach(completedTasksByDate, id: \.date) { data in
                    LineMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Completed", data.count)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue.gradient)
                    
                    PointMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Completed", data.count)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .chartLegend(position: .bottom)
        }
    }
    
    private var taskStatistics: [(category: String, count: Int)] {
        let totalTasks = tasks.count
        let completedTasks = tasks.filter(\.isCompleted).count
        let pendingTasks = totalTasks - completedTasks
        
        return [
            ("Total", totalTasks),
            ("Pending", pendingTasks),
            ("Completed", completedTasks)
        ]
    }
    
    private var completedTasksByDate: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let lastWeekDates = (0..<7).map { days in
            calendar.date(byAdding: .day, value: -days, to: today)!
        }.reversed()
        
        var dateCounts: [Date: Int] = [:]
        let completedTasks = tasks.filter(\.isCompleted)
        
        for task in completedTasks {
            let startOfDay = calendar.startOfDay(for: task.createdAt)
            dateCounts[startOfDay, default: 0] += 1
        }
        
        return lastWeekDates.map { date in
            (date: date, count: dateCounts[date] ?? 0)
        }
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: () -> Content
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            content()
                .frame(height: horizontalSizeClass == .compact ? 180 : 300)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

#Preview {
    AnalyticsView()
}
