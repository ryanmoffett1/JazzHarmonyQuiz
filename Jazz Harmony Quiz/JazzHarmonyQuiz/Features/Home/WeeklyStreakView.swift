import SwiftUI

/// Weekly Streak View - shows M-F practice days
/// Per DESIGN.md Section 5.3.4, using ShedTheme for flat modern UI
struct WeeklyStreakView: View {
    @ObservedObject private var playerProfile = PlayerProfile.shared
    
    var body: some View {
        ShedCard {
            HStack(spacing: ShedTheme.Space.xs) {
                ForEach(weekDays, id: \.self) { day in
                    DayCheckmark(day: day, isCompleted: isDayCompleted(day), isToday: isToday(day))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Data
    
    private let weekDays = ["M", "T", "W", "Th", "F"]
    
    private func isDayCompleted(_ day: String) -> Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let dayIndex = weekDays.firstIndex(of: day) ?? 0
        let targetWeekday = dayIndex + 2 // Monday = 2, Tuesday = 3, etc.
        
        // Check if user has practiced this week
        guard let lastPractice = playerProfile.lastPracticeDate else {
            return false
        }
        
        // Get the start of this week (Monday)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
        
        // If last practice was before this week, no days completed
        guard let weekStart = startOfWeek, lastPractice >= weekStart else {
            return false
        }
        
        // Check if practice streak covers this day
        // If user practiced today with active streak, show past weekdays as completed
        let lastPracticeWeekday = calendar.component(.weekday, from: lastPractice)
        
        // If they practiced on or after this day this week, and have a streak, mark it
        if playerProfile.currentStreak > 0 {
            // Calculate streak start day
            let streakStartWeekday = max(2, lastPracticeWeekday - playerProfile.currentStreak + 1)
            return targetWeekday >= streakStartWeekday && targetWeekday <= lastPracticeWeekday
        }
        
        // Just mark the specific practice day
        return targetWeekday == lastPracticeWeekday
    }
    
    private func isToday(_ day: String) -> Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let dayIndex = weekDays.firstIndex(of: day) ?? 0
        let targetWeekday = dayIndex + 2 // Monday = 2
        return targetWeekday == today
    }
}

/// Individual day checkmark
private struct DayCheckmark: View {
    let day: String
    let isCompleted: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: ShedTheme.Space.xxs) {
            Text(day)
                .font(ShedTheme.Type.caption)
                .foregroundColor(isCompleted ? ShedTheme.Colors.brass : ShedTheme.Colors.textTertiary)
            
            ZStack {
                RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                    .fill(isCompleted ? ShedTheme.Colors.brass.opacity(0.15) : Color.clear)
                    .frame(width: 44, height: 44)
                
                RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                    .stroke(borderColor, lineWidth: ShedTheme.Stroke.thin)
                    .frame(width: 44, height: 44)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ShedTheme.Colors.brass)
                }
            }
        }
    }
    
    private var borderColor: Color {
        if isCompleted {
            return ShedTheme.Colors.brass
        } else if isToday {
            return ShedTheme.Colors.brass.opacity(0.5)
        } else {
            return ShedTheme.Colors.stroke
        }
    }
}

#Preview {
    WeeklyStreakView()
        .padding()
        .background(ShedTheme.Colors.bg)
        .preferredColorScheme(.dark)
}
