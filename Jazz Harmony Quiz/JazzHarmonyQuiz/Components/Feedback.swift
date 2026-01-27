import SwiftUI
import UIKit

// MARK: - Haptic Feedback Helper

enum HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Legacy Feedback Wrappers (Using ShedTheme)

/// Correct answer feedback component
struct CorrectFeedback: View {
    var message: String = "Correct!"
    var showCheckmark: Bool = true
    
    var body: some View {
        ShedFeedback(isCorrect: true, message: message)
    }
}

/// Incorrect answer feedback component
struct IncorrectFeedback: View {
    var message: String = "Incorrect"
    var correctAnswer: String? = nil
    var showXMark: Bool = true
    
    var body: some View {
        ShedFeedback(
            isCorrect: false,
            message: message,
            detail: correctAnswer.map { "Correct answer: \($0)" }
        )
    }
}

// MARK: - Previews

#Preview("Correct Feedback") {
    VStack(spacing: ShedTheme.Space.m) {
        CorrectFeedback()
        CorrectFeedback(message: "Perfect!")
        CorrectFeedback(message: "Great job!", showCheckmark: false)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Incorrect Feedback") {
    VStack(spacing: ShedTheme.Space.m) {
        IncorrectFeedback()
        IncorrectFeedback(message: "Try again")
        IncorrectFeedback(
            message: "Not quite",
            correctAnswer: "Cmaj7"
        )
        IncorrectFeedback(
            message: "Incorrect",
            correctAnswer: "G Major scale",
            showXMark: false
        )
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Feedback Comparison") {
    VStack(spacing: ShedTheme.Space.m) {
        CorrectFeedback(message: "Correct! Perfect 5th")
        IncorrectFeedback(
            message: "Incorrect",
            correctAnswer: "Perfect 4th"
        )
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}
