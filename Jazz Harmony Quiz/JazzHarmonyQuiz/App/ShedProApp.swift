import SwiftUI

@main
struct ShedProApp: App {
    @StateObject private var quizGame = QuizGame()
    @StateObject private var cadenceGame = CadenceGame()
    @StateObject private var scaleGame = ScaleGame()
    @StateObject private var intervalGame = IntervalGame()
    @StateObject private var settings = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quizGame)
                .environmentObject(cadenceGame)
                .environmentObject(scaleGame)
                .environmentObject(intervalGame)
                .environmentObject(settings)
                .preferredColorScheme(settings.colorScheme)
        }
    }
}
