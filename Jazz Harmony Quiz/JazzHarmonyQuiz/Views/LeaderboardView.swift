import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSortOption: SortOption = .score
    @State private var showingClearConfirmation = false
    
    enum SortOption: String, CaseIterable {
        case score = "Best Score"
        case time = "Best Time"
        case recent = "Most Recent"
        
        var systemImage: String {
            switch self {
            case .score:
                return "star.fill"
            case .time:
                return "clock.fill"
            case .recent:
                return "calendar"
            }
        }
    }
    
    var body: some View {
        VStack {
            if quizGame.leaderboard.isEmpty {
                EmptyLeaderboardView()
            } else {
                VStack(spacing: 0) {
                    // Sort Options
                    Picker("Sort by", selection: $selectedSortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            HStack {
                                Image(systemName: option.systemImage)
                                Text(option.rawValue)
                            }
                            .tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: selectedSortOption) { newOption in
                        sortLeaderboard(by: newOption)
                    }
                    
                    // Leaderboard List
                    List(sortedResults, id: \.id) { result in
                        LeaderboardRowView(result: result, rank: sortedResults.firstIndex(of: result)! + 1)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            quizGame.loadLeaderboardFromUserDefaults()
            // Ensure the leaderboard is shown sorted according to the currently selected option
            sortLeaderboard(by: selectedSortOption)
        }
        .onChange(of: quizGame.leaderboard) { _ in
            // If the underlying leaderboard changes elsewhere, keep it sorted according to the selected option
            sortLeaderboard(by: selectedSortOption)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !quizGame.leaderboard.isEmpty {
                    Button("Clear") {
                        showingClearConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("Clear Leaderboard", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearLeaderboard()
            }
        } message: {
            Text("Are you sure you want to clear all leaderboard entries? This action cannot be undone.")
        }
    }
    
    // Now read directly from the model's leaderboard which we explicitly sort when the option changes
    private var sortedResults: [QuizResult] {
        return quizGame.leaderboard
    }
    
    private func sortLeaderboard(by option: SortOption) {
        switch option {
        case .score:
            quizGame.leaderboard.sort { first, second in
                if first.score != second.score {
                    return first.score > second.score
                }
                return first.totalTime < second.totalTime
            }
        case .time:
            quizGame.leaderboard.sort { first, second in
                if first.totalTime != second.totalTime {
                    return first.totalTime < second.totalTime
                }
                return first.score > second.score
            }
        case .recent:
            quizGame.leaderboard.sort { first, second in
                return first.date > second.date
            }
        }
    }
    
    private func clearLeaderboard() {
        quizGame.leaderboard.removeAll()
        quizGame.saveLeaderboardToUserDefaults()
    }
}

struct EmptyLeaderboardView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy")
                .font(.system(size: 80))
                .foregroundColor(settings.secondaryText(for: colorScheme))

            Text("No Results Yet")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(settings.primaryText(for: colorScheme))

            Text("Complete some quizzes to see your results here!")
                .font(.subheadline)
                .foregroundColor(settings.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)

            Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Quiz")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(settings.primaryAccent(for: colorScheme))
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct LeaderboardRowView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let result: QuizResult
    let rank: Int

    var body: some View {
        HStack {
            // Rank
            Text("\(rank)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(settings.primaryText(for: colorScheme))
                .frame(width: 30)

            // Score and Details
            VStack(alignment: .leading, spacing: 4) {
                Text("\(result.score)%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(settings.primaryText(for: colorScheme))

                Text("\(result.correctAnswers)/\(result.totalQuestions)")
                    .font(.subheadline)
                    .foregroundColor(settings.secondaryText(for: colorScheme))

                Text(formatDate(result.date))
                    .font(.caption)
                    .foregroundColor(settings.secondaryText(for: colorScheme))
            }

            Spacer()

            // Time
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatTime(result.totalTime))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(settings.primaryText(for: colorScheme))

                Text("\(formatTime(result.averageTimePerQuestion))/q")
                    .font(.caption)
                    .foregroundColor(settings.secondaryText(for: colorScheme))
            }

            // Trophy for top 3
            if rank <= 3 {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(trophyColor)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
    
    private var trophyColor: Color {
        switch rank {
        case 1:
            return .yellow
        case 2:
            return .gray
        case 3:
            return .orange
        default:
            return .clear
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        LeaderboardView()
            .environmentObject(QuizGame())
    }
}
