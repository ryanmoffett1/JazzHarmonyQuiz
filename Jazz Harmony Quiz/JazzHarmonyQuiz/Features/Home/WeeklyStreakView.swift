import SwiftUI

/// Weekly Streak View - shows M-F practice days
/// Per DESIGN.md Section 5.3.4
struct WeeklyStreakView: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.self) { day in
                DayCheckmark(day: day, isCompleted: isDayCompleted(day))
            }
        }
    }
    
    // MARK: - Data
    
    private let weekDays = ["M", "T", "W", "Th", "F"]
    
    private func isDayCompleted(_ day: String) -> Bool {
        // TODO: Connect to actual PlayerProfile practice history
        // For now, check against current date
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        // Convert weekday to our format (1 = Sunday, 2 = Monday, etc.)
        // Show checkmark for past days this week
        let dayIndex = weekDays.firstIndex(of: day) ?? 0
        let targetWeekday = dayIndex + 2 // Monday = 2, Tuesday = 3, etc.
        
        // Placeholder logic - will be replaced with actual practice history
        return targetWeekday < today
    }
}

/// Individual day checkmark
private struct DayCheckmark: View {
    let day: String
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundColor(isCompleted ? Color("BrassAccent") : .secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCompleted ? Color("BrassAccent").opacity(0.2) : Color.clear)
                    .frame(width: 40, height: 40)
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCompleted ? Color("BrassAccent") : Color.secondary.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("BrassAccent"))
                }
            }
        }
    }
}

#Preview("Light Mode") {
    WeeklyStreakView()
        .padding()
}

#Preview("Dark Mode") {
    WeeklyStreakView()
        .padding()
        .preferredColorScheme(.dark)
}
