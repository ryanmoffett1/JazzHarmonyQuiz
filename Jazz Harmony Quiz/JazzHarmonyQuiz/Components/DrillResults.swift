import SwiftUI

// MARK: - Drill Results Components

/// Shared components for displaying drill results across all drill modules
/// Per DESIGN.md Section 6.3 SESSION COMPLETE layout

// MARK: - Results Score Circle

/// A circular score display showing accuracy percentage
/// Used in all drill results screens
struct ResultsScoreCircle: View {
    let accuracy: Double
    let correctCount: Int
    let totalCount: Int
    var accentColor: Color = .blue
    
    private var accuracyColor: Color {
        if accuracy >= 0.9 { return .green }
        if accuracy >= 0.7 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 140, height: 140)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: accuracy)
                    .stroke(
                        accuracyColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: accuracy)
                
                // Center content
                VStack(spacing: 2) {
                    Text("\(Int(accuracy * 100))%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(accuracyColor)
                    Text("\(correctCount)/\(totalCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Results Stats Grid

/// A grid showing key statistics from a drill session
struct ResultsStatsGrid: View {
    let stats: [ResultsStat]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(stats) { stat in
                ResultsStatCard(stat: stat)
            }
        }
    }
}

/// A single statistic to display in the results
struct ResultsStat: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
    let valueColor: Color
    
    init(icon: String, title: String, value: String, valueColor: Color = .primary) {
        self.icon = icon
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
}

/// Card view for a single statistic
struct ResultsStatCard: View {
    let stat: ResultsStat
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: stat.icon)
                    .foregroundColor(.secondary)
                Text(stat.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(stat.value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(stat.valueColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Results XP Change

/// Display for XP/rating change after a drill session
struct ResultsXPChange: View {
    let ratingChange: Int
    let newRating: Int
    
    private var changeColor: Color {
        ratingChange >= 0 ? .green : .red
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Change
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text(ratingChange >= 0 ? "+" : "")
                    Text("\(ratingChange)")
                }
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(changeColor)
                
                Text("XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // New total
            VStack(spacing: 2) {
                Text("\(newRating)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Results Level Up Celebration

/// Celebratory display when player levels up (simplified per DESIGN.md Section 9.3.1)
struct ResultsLevelUpCelebration: View {
    let previousLevel: Int
    let newLevel: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Level Up!")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Lv.\(previousLevel)")
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundColor(.green)
                
                VStack {
                    Text("Lv.\(newLevel)")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrassAccent"))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color("BrassAccent").opacity(0.3), .orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - Legacy Rank Up Celebration (kept for compatibility)

/// Legacy celebratory display when player ranks up
/// Deprecated: Use ResultsLevelUpCelebration instead
struct ResultsRankUpCelebration: View {
    let previousRank: Rank?
    let newRank: Rank
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🎉 Rank Up! 🎉")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                if let prev = previousRank {
                    VStack {
                        Text(prev.emoji)
                            .font(.system(size: 36))
                        Text(prev.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundColor(.green)
                
                VStack {
                    Text(newRank.emoji)
                        .font(.system(size: 44))
                    Text(newRank.title)
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
}

// MARK: - Results Action Buttons

/// Standard action buttons for drill results screens
struct ResultsActionButtons: View {
    let primaryAction: () -> Void
    let primaryTitle: String
    let primaryIcon: String
    let primaryColor: Color
    let secondaryDestination: AnyView?
    let secondaryTitle: String
    let secondaryIcon: String
    let secondaryColor: Color
    
    init(
        primaryTitle: String = "New Quiz",
        primaryIcon: String = "arrow.counterclockwise",
        primaryColor: Color = .blue,
        primaryAction: @escaping () -> Void,
        secondaryTitle: String = "View Scoreboard",
        secondaryIcon: String = "trophy.fill",
        secondaryColor: Color = .orange,
        secondaryDestination: AnyView? = nil
    ) {
        self.primaryTitle = primaryTitle
        self.primaryIcon = primaryIcon
        self.primaryColor = primaryColor
        self.primaryAction = primaryAction
        self.secondaryTitle = secondaryTitle
        self.secondaryIcon = secondaryIcon
        self.secondaryColor = secondaryColor
        self.secondaryDestination = secondaryDestination
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Primary button (New Quiz)
            Button(action: primaryAction) {
                HStack {
                    Image(systemName: primaryIcon)
                    Text(primaryTitle)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(primaryColor)
                .cornerRadius(12)
            }
            
            // Secondary button (Scoreboard)
            if let destination = secondaryDestination {
                NavigationLink(destination: destination) {
                    HStack {
                        Image(systemName: secondaryIcon)
                        Text(secondaryTitle)
                    }
                    .font(.headline)
                    .foregroundColor(secondaryColor)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(secondaryColor.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(secondaryColor, lineWidth: 1.5)
                    )
                }
            }
        }
    }
}

// MARK: - Results Header

/// Standard header for drill results with emoji and title
struct ResultsHeader: View {
    let accuracy: Double
    let drillName: String
    
    private var resultEmoji: String {
        if accuracy >= 0.95 { return "🏆" }
        if accuracy >= 0.9 { return "🌟" }
        if accuracy >= 0.8 { return "👏" }
        if accuracy >= 0.7 { return "👍" }
        if accuracy >= 0.5 { return "💪" }
        return "📚"
    }
    
    private var resultTitle: String {
        if accuracy >= 0.95 { return "Perfect!" }
        if accuracy >= 0.9 { return "Excellent!" }
        if accuracy >= 0.8 { return "Great Job!" }
        if accuracy >= 0.7 { return "Good Work!" }
        if accuracy >= 0.5 { return "Keep Practicing!" }
        return "Keep Learning!"
    }
    
    private var resultSubtitle: String {
        if accuracy >= 0.9 { return "Outstanding \(drillName) skills!" }
        if accuracy >= 0.7 { return "You're making great progress!" }
        return "Practice makes perfect!"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(resultEmoji)
                .font(.system(size: 70))
            
            Text(resultTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(resultSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
}

// MARK: - Results Time Display

/// Standard time display showing duration and average time per question
struct ResultsTimeDisplay: View {
    let totalTime: TimeInterval
    let questionCount: Int
    
    private var formattedTime: String {
        let minutes = Int(totalTime) / 60
        let seconds = Int(totalTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var averageTime: Double {
        guard questionCount > 0 else { return 0 }
        return totalTime / Double(questionCount)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
            Text(formattedTime)
            Spacer()
            Text("(\(String(format: "%.1f", averageTime))s avg)")
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}

// MARK: - Previews

#Preview("Score Circle") {
    VStack(spacing: 20) {
        ResultsScoreCircle(accuracy: 0.95, correctCount: 19, totalCount: 20)
        ResultsScoreCircle(accuracy: 0.75, correctCount: 15, totalCount: 20)
        ResultsScoreCircle(accuracy: 0.45, correctCount: 9, totalCount: 20)
    }
    .padding()
}

#Preview("Stats Grid") {
    ResultsStatsGrid(stats: [
        ResultsStat(icon: "checkmark.circle", title: "Correct", value: "15/20", valueColor: .green),
        ResultsStat(icon: "clock", title: "Time", value: "3:45"),
        ResultsStat(icon: "bolt", title: "XP", value: "+25", valueColor: .yellow),
        ResultsStat(icon: "flame", title: "Streak", value: "5 days", valueColor: .orange)
    ])
    .padding()
}

#Preview("Level Up") {
    ResultsLevelUpCelebration(
        previousLevel: 4,
        newLevel: 5
    )
    .padding()
}

#Preview("Rank Up (Legacy)") {
    ResultsRankUpCelebration(
        previousRank: Rank.allRanks[2],
        newRank: Rank.allRanks[3]
    )
    .padding()
}

#Preview("Results Header") {
    VStack(spacing: 30) {
        ResultsHeader(accuracy: 0.95, drillName: "chord")
        ResultsHeader(accuracy: 0.65, drillName: "scale")
    }
}
