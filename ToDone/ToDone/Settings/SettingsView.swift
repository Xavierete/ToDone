import SwiftUI

enum AccentColorOption: String, CaseIterable {
    case green = "Green"
    case blue = "Blue"
    case red = "Red"
    case orange = "Orange"
    case purple = "Purple"
    case pink = "Pink"
    case yellow = "Yellow"
    case mint = "Mint"
    case teal = "Teal"
    case indigo = "Indigo"
    case brown = "Brown"
    
    var color: Color {
        switch self {
        case .green:
            return .green
        case .blue:
            return .blue
        case .red:
            return .red
        case .orange:
            return .orange
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .yellow:
            return .yellow
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .indigo:
            return .indigo
        case .brown:
            return .brown
        }
    }
}

enum AppTheme: Int {
    case system = 0
    case light = 1
    case dark = 2
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("accentColor") private var accentColor: AccentColorOption = .green
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    // Theme Picker
                    Picker(selection: $appTheme) {
                        ForEach([AppTheme.system, .light, .dark], id: \.self) { theme in
                            Text(theme == .system ? "System" :
                                    theme == .light ? "Light" : "Dark")
                                .tag(theme)
                        }
                    } label: {
                        Text("Theme")
                            .bold()
                    }
                    
                    // Accent Color Picker
                    accentColorPicker
                }
                
                // App Icon Section
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image("ToDoneLogo")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(20)
                            
                            Text("ToDone")
                                .font(.headline)
                            
                            Text("Version 1.2a")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var accentColorPicker: some View {
        Picker(selection: $accentColor) {
            ForEach(AccentColorOption.allCases, id: \.self) { option in
                HStack {
                    Circle()
                        .fill(option.color)
                        .frame(width: 20, height: 20)
                    Text(option.rawValue)
                }
                .tag(option)
            }
        } label: {
            Text("Accent Color")
                .bold()
                .foregroundColor(accentColor.color)
        }
        .tint(.secondary)
    }
}

#Preview {
    SettingsView()
} 
