import SwiftUI

@main
struct JazzHarmonyQuizApp: App {
    @StateObject private var quizGame = QuizGame()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ChordDrillView()
                    .environmentObject(quizGame)
            }
        }
    }
}
