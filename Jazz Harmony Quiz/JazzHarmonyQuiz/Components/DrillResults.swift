import SwiftUI

// MARK: - Drill Results Data Protocol

/// Protocol for drill result data that can be displayed in DrillResultsView
protocol DrillResultData {
    var correctAnswers: Int { get }
    var totalQuestions: Int { get }
    var accuracy: Double { get }
    var totalTime: TimeInterval { get }
    var averageTimePerQuestion: Double { get }
}

// MARK: - Drill Results View

/// Shared results view component for all drill types
/// Per DESIGN.md Section 6.3 (SESSION COMPLETE layout)
struct DrillResultsView<Content: View>: View {
    let result: DrillResultData
    let ratingChange: Int
    let didRankUp: Bool
    let previousRank: Rank?
    let currentRank: Rank
    let currentRating: Int
    let currentStreak: Int
    let onNewQuiz: () -> Void
    let onBackToSetup: () -> Void
    let additionalContent: (() -> Content)?
    
    init(
        result: DrillResultData,
        ratingChange: Int,
        didRankUp: Bool,
        previousRank: Rank?,
        currentRank: Rank,
        currentRating: Int,
        currentStreak: Int = 0,
        onNewQuiz: @escaping () -> Void,
        onBackToSetup: @escaping () -> Void,
        @ViewBuilder additionalContent: @escaping () -> Content
    ) {
        self.result = result
        self.ratingChange = ratingChange
        self.didRankUp = didRankUp
        self.previousRank = previousRank
        self.currentRank = currentRank
        self.currentRating = currentRating
        self.currentStreak = currentStreak
        self.onNewQuiz = onNewQuiz
        self.onBackToSetup = onBackToSetup
        self.additionalContent = additionalContent
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Rank Up Celebration (if applicable)
                if didRankUp {
                    rankUpCelebration
                }
                
                // Header
                resultsHeader
                
                // Score Display
                scoreDisplay
                
                // XP and Rating Info
                xpRatingSection
                
                // Streak Info
                if currentStreak > 1 {
                    streakBadge
                }
                
                // Time Info
                timeSection
                
                // Additional content (e.g., missed questions, scoreboard)
                if let content = additionalContent {
                    content()
                }
                
                // Action Buttons
                actionButtons
                
                Spacer(minLength: 20)
            }
            .padding()
        }
    }
    
    // MARK: - Rank Up Celebration
    
    private var rankUpCelebration: some View {
        VStack(spacing: 12) {
            Text("🎉 Rank Up! 🎉")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                if let prev = previousRank {
                    VStack {
                        Text(prev.emoji)
                            .font(.system(size: 40))
                        Text(prev.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack {
                    Text(currentRank.emoji)
                        .font(.system(size: 50))
                    Text(currentRank.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    // MARK: - Results Header
    
    private var resultsHeader: some View {
        VStack(spacing: 12) {
            Text(resultEmoji)
                .font(.system(size: 60))
            
            Text("Session Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(resultSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Score Display
    
    private var scoreDisplay: some View {
        VStack(spacing: 16) {
            // Accuracy percentage
            Text("\(Int(result.accuracy * 100))%")
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(accuracyColor)
            
            // Correct count
            Text("\(result.correctAnswers) of \(result.totalQuestions) correct")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - XP and Rating Section
    
    private var xpRatingSection: some View {
        HStack(spacing: 16) {
            // XP Change
            VStack {
                HStack(spacing: 4) {
                    Text(ratingChange >= 0 ? "+" : "")
                    Text("\(ratingChange)")
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ratingChange >= 0 ? .green : .red)
                
                Text("XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // Total Rating
            VStack {
                Text("\(currentRating)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // Current Rank
            VStack {
                Text(currentRank.emoji)
                    .font(.title)
                Text(currentRank.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Streak Badge
    
    private var streakBadge: some View {
        HStack {
            Text("🔥")
            Text("\(currentStreak) day streak!")
        }
        .font(.headline)
        .foregroundColor(.orange)
    }
    
    // MARK: - Time Section
    
    private var timeSection: some View {
        HStack(spacing: 20) {
            HStack {
                Image(systemName: "clock")
                Text(formatTime(result.totalTime))
            }
            
            HStack {
                Image(systemName: "timer")
                Text("\(String(format: "%.1f", result.averageTimePerQuestion))s avg")
            }
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // New Quiz (Primary)
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
            
            // Back to Setup (Secondary)
            Button(action: onBackToSetup) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Change Settings")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var resultEmoji: String {
        let accuracy = result.accuracy
        if accuracy >= 0.9 { return "🌟" }
        if accuracy >= 0.8 { return "🎉" }
        if accuracy >= 0.7 { return "👍" }
        if accuracy >= 0.5 { return "💪" }
        return "📚"
    }
    
    private var resultSubtitle: String {
        let accuracy = result.accuracy
        if accuracy >= 0.9 { return "Outstanding performance!" }
        if accuracy >= 0.8 { return "Great job!" }
        if accuracy >= 0.7 { return "Good work!" }
        if accuracy >= 0.5 { return "Keep practicing!" }
        return "Room for improvement"
    }
    
    private var accuracyColor: Color {
        let accuracy = result.accuracy
        if accuracy >= 0.9 { return .green }
        if accuracy >= 0.7 { return .orange }
        return .red
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Convenience Initializer (No Additional Content)

extension DrillResultsView where Content == EmptyView {
    init(
        result: DrillResultData,
        ratingChange: Int,
        didRankUp: Bool,
        previousRank: Rank?,
        currentRank: Rank,
        currentRating: Int,
        currentStreak: Int = 0,
        onNewQuiz: @escaping () -> Void,
        onBackToSetup: @escaping () -> Void
    ) {
        self.result = result
        self.ratingChange = ratingChange
        self.didRankUp = didRankUp
        self.previousRank = previousRank
        self.currentRank = currentRank
        self.currentRating = currentRating
        self.currentStreak = currentStreak
        self.onNewQuiz = onNewQuiz
        self.onBackToSetup = onBackToSetup
        self.additionalContent = nil
    }
}

// MARK: - Simple Result Struct

/// Simple struct for basic drill results that don't have a custom result type
struct SimpleDrillResult: DrillResultData {
    let correctAnswers: Int
    let totalQuestions: Int
    let totalTime: TimeInterval
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var averageTimePerQuestion: Double {
        guard totalQuestions > 0 else { return 0 }
        return totalTime / Double(totalQuestions)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DrillResultsView(
            result: SimpleDrillResult(correctAnswers: 8, totalQuestions: 10, totalTime: 120),
            ratingChange: 25,
            didRankUp: false,
            previousRank: nil,
            currentRank: Rank.forRating(1250),
            currentRating: 1250,
            currentStreak: 3,
            onNewQuiz: {},
            onBackToSetup: {}
        )
    }
}
