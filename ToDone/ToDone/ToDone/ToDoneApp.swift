import SwiftUI
import SwiftData

@main
struct ToDoneApp: App {
    let container: ModelContainer
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("accentColor") private var accentColor: AccentColorOption = .green
    
    init() {
        let schema = Schema([Task.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(appTheme.colorScheme)
                .tint(accentColor.color)
        }
        .modelContainer(container)
    }
}
