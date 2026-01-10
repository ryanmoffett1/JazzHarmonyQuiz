import SwiftUI

@main
struct JazzHarmonyQuizApp: App {
    @StateObject private var quizGame = QuizGame()
    @StateObject private var settings = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ChordDrillView()
                    .environmentObject(quizGame)
                    .environmentObject(settings)
            }
            .preferredColorScheme(settings.colorScheme)
        }
    }
}
