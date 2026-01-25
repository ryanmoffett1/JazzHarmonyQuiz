import SwiftUI

/// Root view with tab-based navigation per DESIGN.md Section 3.1
struct ContentView: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            // Practice Tab (Drill Selection)
            PracticeView()
                .tabItem {
                    Label("Practice", systemImage: "music.note.list")
                }
                .tag(1)
            
            // Curriculum Tab
            CurriculumView()
                .tabItem {
                    Label("Curriculum", systemImage: "book")
                }
                .tag(2)
            
            // Progress Tab
            ProgressTabView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(4)
        }
        .tint(Color("BrassAccent"))
    }
}

#Preview("Light Mode") {
    ContentView()
        .environmentObject(SettingsManager.shared)
}

#Preview("Dark Mode") {
    ContentView()
        .environmentObject(SettingsManager.shared)
        .preferredColorScheme(.dark)
}
