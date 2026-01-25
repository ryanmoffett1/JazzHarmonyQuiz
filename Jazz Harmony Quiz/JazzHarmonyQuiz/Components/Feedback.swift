import SwiftUI

/// Correct answer feedback component
struct CorrectFeedback: View {
    var message: String = "Correct!"
    var showCheckmark: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            if showCheckmark {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            Text(message)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
        )
    }
}

/// Incorrect answer feedback component
struct IncorrectFeedback: View {
    var message: String = "Incorrect"
    var correctAnswer: String? = nil
    var showXMark: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if showXMark {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                
                Text(message)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundColor(.red)
            }
            
            if let correctAnswer = correctAnswer {
                Text("Correct answer: \(correctAnswer)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
        )
    }
}

// MARK: - Previews

#Preview("Correct Feedback") {
    VStack(spacing: 20) {
        CorrectFeedback()
        CorrectFeedback(message: "Perfect!")
        CorrectFeedback(message: "Great job!", showCheckmark: false)
    }
    .padding()
}

#Preview("Incorrect Feedback") {
    VStack(spacing: 20) {
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
    .padding()
}

#Preview("Feedback Comparison") {
    VStack(spacing: 20) {
        CorrectFeedback(message: "Correct! Perfect 5th")
        IncorrectFeedback(
            message: "Incorrect",
            correctAnswer: "Perfect 4th"
        )
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: 20) {
        CorrectFeedback(message: "Excellent!")
        IncorrectFeedback(
            message: "Incorrect",
            correctAnswer: "Dm7"
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
