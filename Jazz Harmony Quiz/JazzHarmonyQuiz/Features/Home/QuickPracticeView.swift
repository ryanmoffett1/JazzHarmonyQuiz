import SwiftUI

/// Quick Practice View - directly starts a mixed practice session
/// Per DESIGN.md Section 6.2 and Appendix C.2
/// 
/// DESIGN CONTRACT: Quick Practice must launch a mixed session without setup screens.
/// Users should be drilling within seconds of tapping "Quick Practice" on Home.
struct QuickPracticeView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Directly present the session - no navigation hub
        QuickPracticeSession()
            .environmentObject(settings)
    }
}

#Preview {
    QuickPracticeView()
        .environmentObject(SettingsManager.shared)
}
