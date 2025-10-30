import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Tasks", systemImage: "pencil.and.list.clipboard")
                }
            
            CompletedView()
                .tabItem {
                    Label("Completed", systemImage: "checkmark.arrow.trianglehead.counterclockwise")
                }
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}

#Preview {
    ContentView()
}
