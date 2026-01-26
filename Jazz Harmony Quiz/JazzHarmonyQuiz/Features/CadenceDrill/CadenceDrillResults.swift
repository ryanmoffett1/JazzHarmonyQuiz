import SwiftUI

// MARK: - Cadence Drill Results View

/// Results screen shown after completing a cadence drill session
/// Displays score, XP changes, rank, and action buttons
struct CadenceDrillResults: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let onNewQuiz: () -> Void
    
    private var encouragement: EncouragementMessage? {
        cadenceGame.getEncouragementMessage()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if let result = cadenceGame.currentResult {
                    // Encouragement Message (Phase 5)
                    encouragementSection
                    
                    // Header
                    headerSection
                    
                    // Score Display
                    scoreDisplaySection(result: result)

                    // Action Buttons
                    actionButtonsSection(result: result)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Encouragement Section
    
    @ViewBuilder
    private var encouragementSection: some View {
        if let message = encouragement {
            VStack(spacing: 8) {
                Text(message.emoji)
                    .font(.system(size: 50))
                Text(message.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(encouragementColor(for: message.type))
                Text(message.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(encouragementColor(for: message.type).opacity(0.1))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Header Section
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 8) {
            if encouragement == nil {
                Text("Quiz Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // Streak encouragement
            if let streakMessage = cadenceGame.getStreakEncouragement() {
                Text(streakMessage)
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            } else if cadenceGame.currentStreak > 1 {
                HStack {
                    Text("🔥")
                    Text("\(cadenceGame.currentStreak) day streak!")
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Score Display Section
    
    @ViewBuilder
    private func scoreDisplaySection(result: CadenceResult) -> some View {
        VStack(spacing: 20) {
            // Accuracy
            VStack(spacing: 10) {
                Text("\(Int(result.accuracy * 100))%")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(accuracyColor(result.accuracy))

                Text("Accuracy")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            // Stats
            HStack(spacing: 40) {
                VStack {
                    Text("\(result.correctAnswers)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Correct")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(result.totalQuestions - result.correctAnswers)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Incorrect")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(Int(result.totalTime))s")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Total Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Cadence Type and Mode
            VStack(spacing: 4) {
                Text("Cadence Type: \(result.cadenceType.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Mode: \(cadenceGame.selectedDrillMode.description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if cadenceGame.useMixedCadences {
                    Text("Mixed Cadences Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Key Difficulty: \(cadenceGame.selectedKeyDifficulty.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // XP Change Display
            xpDisplaySection
            
            // Rank Up Celebration
            rankUpSection
            
            // Points to next rank
            if let pointsNeeded = cadenceGame.playerStats.pointsToNextRank {
                Text("\(pointsNeeded) points to next rank")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - XP Display Section
    
    @ViewBuilder
    private var xpDisplaySection: some View {
        HStack(spacing: 16) {
            VStack {
                HStack(spacing: 4) {
                    Text(cadenceGame.lastRatingChange >= 0 ? "+" : "")
                    Text("\(cadenceGame.lastRatingChange)")
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(cadenceGame.lastRatingChange >= 0 ? .green : .red)
                
                Text("XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("\(cadenceGame.playerStats.currentRating)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text(cadenceGame.playerStats.currentRank.emoji)
                    .font(.title)
                Text(cadenceGame.playerStats.currentRank.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
    
    // MARK: - Rank Up Section
    
    @ViewBuilder
    private var rankUpSection: some View {
        if cadenceGame.didRankUp {
            HStack(spacing: 8) {
                if let prev = cadenceGame.previousRank {
                    Text(prev.emoji)
                }
                Image(systemName: "arrow.right")
                    .foregroundColor(.green)
                Text(cadenceGame.playerStats.currentRank.emoji)
                Text("Rank Up!")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .font(.headline)
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Action Buttons Section
    
    @ViewBuilder
    private func actionButtonsSection(result: CadenceResult) -> some View {
        VStack(spacing: 15) {
            // Mistake Review Drill (only if there are missed questions)
            if cadenceGame.hasMissedQuestions {
                Button(action: {
                    cadenceGame.startMistakeReviewDrill()
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Drill Missed Chords (\(cadenceGame.getMissedQuestions().count))")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
                }
            }
            
            if result.correctAnswers < result.totalQuestions {
                NavigationLink(destination: CadenceReviewView()) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Review Wrong Answers")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                }
            }

            Button(action: onNewQuiz) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("New Quiz")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helpers

    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.9 {
            return .green
        } else if accuracy >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func encouragementColor(for type: EncouragementMessage.MessageType) -> Color {
        switch type {
        case .celebration:
            return .yellow
        case .positive:
            return .green
        case .encouraging:
            return .blue
        case .milestone:
            return .purple
        }
    }
}

// MARK: - Cadence Review View

/// View for reviewing incorrect answers after a quiz
struct CadenceReviewView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme

    var incorrectQuestions: [(question: CadenceQuestion, userAnswer: [[Note]])] {
        guard let result = cadenceGame.currentResult else { return [] }

        return result.questions.compactMap { question in
            let isCorrect = result.isCorrect[question.id.uuidString] ?? false
            if !isCorrect {
                let userAnswer = result.userAnswers[question.id.uuidString] ?? [[], [], []]
                return (question, userAnswer)
            }
            return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Wrong Answers Review")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                if incorrectQuestions.isEmpty {
                    Text("No incorrect answers to review!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(incorrectQuestions.enumerated()), id: \.offset) { index, item in
                        cadenceQuestionCard(question: item.question, userAnswer: item.userAnswer, index: index + 1)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Review")
    }

    private func cadenceQuestionCard(question: CadenceQuestion, userAnswer: [[Note]], index: Int) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Question \(index)")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))

            Text("Cadence: \(question.cadence.key.name) \(question.cadence.cadenceType.rawValue)")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(0..<3, id: \.self) { i in
                VStack(alignment: .leading, spacing: 5) {
                    Text("Chord \(i + 1): \(question.cadence.chords[i].displayName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack {
                        Text("Your answer:")
                            .font(.caption)
                        Text(userAnswer[i].map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    HStack {
                        Text("Correct answer:")
                            .font(.caption)
                        Text(question.correctAnswers[i].map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CadenceDrillResults(onNewQuiz: {})
            .environmentObject(CadenceGame())
            .environmentObject(SettingsManager.shared)
    }
}
