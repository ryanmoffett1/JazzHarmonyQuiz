import Foundation
import SwiftUI

// MARK: - SR Item Identifier

/// Uniquely identifies a practice item across all modes
struct SRItemID: Hashable, Codable {
    let mode: PracticeMode
    let topic: String      // chord symbol, scale name, cadence type, interval name
    let key: String?       // optional root note/key (e.g., "C", "F#")
    let variant: String?   // optional variant (e.g., "V7b9", "ascending", "isolated-ii")
    
    init(mode: PracticeMode, topic: String, key: String? = nil, variant: String? = nil) {
        self.mode = mode
        self.topic = topic
        self.key = key
        self.variant = variant
    }
    
    /// Human-readable description for UI
    var displayName: String {
        var parts: [String] = []
        
        if let key = key {
            parts.append(key)
        }
        
        parts.append(topic)
        
        if let variant = variant {
            parts.append("(\(variant))")
        }
        
        return parts.joined(separator: " ")
    }
    
    /// Short description for compact UI
    var shortName: String {
        if let key = key {
            return "\(key) \(topic)"
        }
        return topic
    }
}

// MARK: - SR Schedule

/// Spaced repetition schedule using simplified SM-2 algorithm
struct SRSchedule: Codable {
    var easeFactor: Double = 2.5        // 1.3 to 3.0, higher = easier for user
    var intervalDays: Double = 1.0      // Days until next review
    var repetitions: Int = 0            // Number of successful reviews
    var dueDate: Date                   // When this item should be reviewed
    var lastReviewedDate: Date?         // Last time reviewed
    var lastResultWasCorrect: Bool = false
    var totalReviews: Int = 0           // Total times reviewed (correct or not)
    var totalCorrect: Int = 0           // Total correct reviews
    
    /// Accuracy percentage for this item
    var accuracy: Double {
        guard totalReviews > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalReviews)
    }
    
    /// Is this item currently due for review?
    func isDue(for date: Date = Date()) -> Bool {
        return dueDate <= date
    }
    
    /// Days until next review (negative if overdue)
    func daysUntilDue(from date: Date = Date()) -> Int {
        let interval = Calendar.current.dateComponents([.day], from: date, to: dueDate)
        return interval.day ?? 0
    }
    
    /// Maturity level based on interval
    var maturityLevel: MaturityLevel {
        if intervalDays < 1 {
            return .new
        } else if intervalDays < 7 {
            return .learning
        } else if intervalDays < 21 {
            return .young
        } else {
            return .mature
        }
    }
    
    enum MaturityLevel: String {
        case new = "New"
        case learning = "Learning"
        case young = "Young"
        case mature = "Mature"
    }
}

// MARK: - Spaced Repetition Store

/// Manages spaced repetition schedules for all practice items
@MainActor
class SpacedRepetitionStore: ObservableObject {
    static let shared = SpacedRepetitionStore()
    
    @Published var schedules: [SRItemID: SRSchedule] = [:]
    
    private let storageKey = "SpacedRepetitionSchedules"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        load()
    }
    
    // MARK: - Query Methods
    
    /// Get all items due for review
    func dueItems(for date: Date = Date()) -> [SRItemID] {
        schedules.filter { $0.value.isDue(for: date) }
            .map { $0.key }
            .sorted { lhs, rhs in
                // Sort by due date (most overdue first)
                guard let lhsSchedule = schedules[lhs],
                      let rhsSchedule = schedules[rhs] else {
                    return false
                }
                return lhsSchedule.dueDate < rhsSchedule.dueDate
            }
    }
    
    /// Get items due for a specific mode
    func dueItems(for mode: PracticeMode, date: Date = Date()) -> [SRItemID] {
        dueItems(for: date).filter { $0.mode == mode }
    }
    
    /// Count of items due per mode
    func dueCount(for mode: PracticeMode, date: Date = Date()) -> Int {
        dueItems(for: mode, date: date).count
    }
    
    /// Total count of items due across all modes
    func totalDueCount(for date: Date = Date()) -> Int {
        dueItems(for: date).count
    }
    
    /// Get schedule for an item (creates new if doesn't exist)
    func schedule(for itemID: SRItemID) -> SRSchedule {
        if let existing = schedules[itemID] {
            return existing
        }
        
        // Create new schedule
        let newSchedule = SRSchedule(dueDate: Date())
        schedules[itemID] = newSchedule
        save()
        return newSchedule
    }
    
    /// Check if an item exists in the system
    func hasSchedule(for itemID: SRItemID) -> Bool {
        schedules[itemID] != nil
    }
    
    // MARK: - Recording Results
    
    /// Record a practice result and update schedule using SM-2 algorithm
    func recordResult(
        itemID: SRItemID,
        wasCorrect: Bool,
        responseTime: TimeInterval? = nil
    ) {
        var schedule = self.schedule(for: itemID)
        
        schedule.lastReviewedDate = Date()
        schedule.lastResultWasCorrect = wasCorrect
        schedule.totalReviews += 1
        
        if wasCorrect {
            schedule.totalCorrect += 1
            schedule.repetitions += 1
            
            // SM-2 algorithm for correct answers
            let quality = calculateQuality(responseTime: responseTime)
            
            // Update ease factor: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
            schedule.easeFactor = max(1.3, schedule.easeFactor + (0.1 - (5.0 - quality) * (0.08 + (5.0 - quality) * 0.02)))
            
            // Update interval based on repetition count
            if schedule.repetitions == 1 {
                schedule.intervalDays = 1
            } else if schedule.repetitions == 2 {
                schedule.intervalDays = 6
            } else {
                schedule.intervalDays = schedule.intervalDays * schedule.easeFactor
            }
            
        } else {
            // Incorrect answer: reset to beginning but keep ease factor
            schedule.repetitions = 0
            schedule.intervalDays = 1
            schedule.easeFactor = max(1.3, schedule.easeFactor - 0.2) // Reduce ease slightly
        }
        
        // Set next due date
        schedule.dueDate = Calendar.current.date(
            byAdding: .day,
            value: Int(schedule.intervalDays),
            to: Date()
        ) ?? Date()
        
        schedules[itemID] = schedule
        save()
    }
    
    /// Calculate quality score (0-5) based on response time
    /// Faster responses = higher quality = longer intervals
    private func calculateQuality(responseTime: TimeInterval?) -> Double {
        guard let time = responseTime else { return 4.0 } // Default to "good"
        
        // Quality scoring based on speed:
        // < 2s = 5 (perfect)
        // 2-5s = 4 (good)
        // 5-10s = 3 (okay)
        // 10-20s = 2 (hard)
        // 20s+ = 1 (very hard, but still correct)
        
        if time < 2 {
            return 5.0
        } else if time < 5 {
            return 4.0
        } else if time < 10 {
            return 3.0
        } else if time < 20 {
            return 2.5
        } else {
            return 2.0
        }
    }
    
    /// Reset an item to initial state (useful for "start over")
    func resetItem(_ itemID: SRItemID) {
        schedules[itemID] = SRSchedule(dueDate: Date())
        save()
    }
    
    /// Remove an item completely
    func removeItem(_ itemID: SRItemID) {
        schedules.removeValue(forKey: itemID)
        save()
    }
    
    /// Reset all schedules (useful for testing or complete restart)
    func resetAll() {
        schedules.removeAll()
        save()
    }
    
    // MARK: - Statistics
    
    /// Get statistics about the SR system
    func statistics() -> SRStatistics {
        let total = schedules.count
        let due = dueItems().count
        
        let byMaturity = schedules.values.reduce(into: [SRSchedule.MaturityLevel: Int]()) { counts, schedule in
            counts[schedule.maturityLevel, default: 0] += 1
        }
        
        let averageAccuracy = schedules.values.isEmpty ? 0 :
            schedules.values.map { $0.accuracy }.reduce(0, +) / Double(schedules.count)
        
        return SRStatistics(
            totalItems: total,
            dueItems: due,
            newItems: byMaturity[.new] ?? 0,
            learningItems: byMaturity[.learning] ?? 0,
            youngItems: byMaturity[.young] ?? 0,
            matureItems: byMaturity[.mature] ?? 0,
            averageAccuracy: averageAccuracy
        )
    }
    
    // MARK: - Persistence
    
    func save() {
        do {
            let data = try encoder.encode(schedules)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save SR schedules: \(error)")
        }
    }
    
    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }
        
        do {
            schedules = try decoder.decode([SRItemID: SRSchedule].self, from: data)
        } catch {
            print("Failed to load SR schedules: \(error)")
            schedules = [:]
        }
    }
}

// MARK: - Statistics

struct SRStatistics {
    let totalItems: Int
    let dueItems: Int
    let newItems: Int
    let learningItems: Int
    let youngItems: Int
    let matureItems: Int
    let averageAccuracy: Double
}
