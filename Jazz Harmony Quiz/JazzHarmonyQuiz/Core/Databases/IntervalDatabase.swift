import Foundation

/// Database of all musical intervals organized by difficulty
class IntervalDatabase {
    static let shared = IntervalDatabase()
    
    private init() {}
    
    // MARK: - All Intervals
    
    /// Complete list of intervals from unison to compound intervals
    let allIntervals: [IntervalType] = [
        // Beginner - Perfect intervals and basic major/minor
        // Note: Unison (P1, 0 semitones) intentionally excluded - ambiguous in quiz context
        // (e.g., "F to F" could mean unison or octave, user can't tell which)
        IntervalType(
            name: "Minor Second",
            shortName: "m2",
            semitones: 1,
            quality: .minor,
            number: 2,
            difficulty: .intermediate
        ),
        IntervalType(
            name: "Major Second",
            shortName: "M2",
            semitones: 2,
            quality: .major,
            number: 2,
            difficulty: .beginner
        ),
        IntervalType(
            name: "Minor Third",
            shortName: "m3",
            semitones: 3,
            quality: .minor,
            number: 3,
            difficulty: .beginner
        ),
        IntervalType(
            name: "Major Third",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            number: 3,
            difficulty: .beginner
        ),
        IntervalType(
            name: "Perfect Fourth",
            shortName: "P4",
            semitones: 5,
            quality: .perfect,
            number: 4,
            difficulty: .beginner
        ),
        IntervalType(
            name: "Tritone",
            shortName: "TT",
            semitones: 6,
            quality: .augmented,
            number: 4,
            difficulty: .intermediate
        ),
        IntervalType(
            name: "Perfect Fifth",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            number: 5,
            difficulty: .beginner
        ),
        IntervalType(
            name: "Minor Sixth",
            shortName: "m6",
            semitones: 8,
            quality: .minor,
            number: 6,
            difficulty: .intermediate
        ),
        IntervalType(
            name: "Major Sixth",
            shortName: "M6",
            semitones: 9,
            quality: .major,
            number: 6,
            difficulty: .intermediate
        ),
        IntervalType(
            name: "Minor Seventh",
            shortName: "m7",
            semitones: 10,
            quality: .minor,
            number: 7,
            difficulty: .intermediate
        ),
        IntervalType(
            name: "Major Seventh",
            shortName: "M7",
            semitones: 11,
            quality: .major,
            number: 7,
            difficulty: .intermediate
        ),
        // Note: Octave (P8, 12 semitones) intentionally excluded - ambiguous in quiz context
        // (user can't tell which octave to select on piano keyboard)
        
        // Advanced - Compound intervals
        IntervalType(
            name: "Minor Ninth",
            shortName: "m9",
            semitones: 13,
            quality: .minor,
            number: 9,
            difficulty: .advanced
        ),
        IntervalType(
            name: "Major Ninth",
            shortName: "M9",
            semitones: 14,
            quality: .major,
            number: 9,
            difficulty: .advanced
        ),
        IntervalType(
            name: "Minor Tenth",
            shortName: "m10",
            semitones: 15,
            quality: .minor,
            number: 10,
            difficulty: .advanced
        ),
        IntervalType(
            name: "Major Tenth",
            shortName: "M10",
            semitones: 16,
            quality: .major,
            number: 10,
            difficulty: .advanced
        ),
        IntervalType(
            name: "Perfect Eleventh",
            shortName: "P11",
            semitones: 17,
            quality: .perfect,
            number: 11,
            difficulty: .advanced
        ),
        IntervalType(
            name: "Augmented Eleventh",
            shortName: "A11",
            semitones: 18,
            quality: .augmented,
            number: 11,
            difficulty: .advanced
        ),
        IntervalType(
            name: "Perfect Twelfth",
            shortName: "P12",
            semitones: 19,
            quality: .perfect,
            number: 12,
            difficulty: .advanced
        ),
        IntervalType(
            name: "Minor Thirteenth",
            shortName: "m13",
            semitones: 20,
            quality: .minor,
            number: 13,
            difficulty: .advanced
        ),
        IntervalType(
            name: "Major Thirteenth",
            shortName: "M13",
            semitones: 21,
            quality: .major,
            number: 13,
            difficulty: .advanced
        ),
    ]
    
    // MARK: - Filtered Access
    
    /// Get intervals up to and including the specified difficulty
    func intervals(for difficulty: IntervalDifficulty) -> [IntervalType] {
        allIntervals.filter { $0.difficulty <= difficulty }
    }
    
    /// Get intervals with specific qualities
    func intervals(withQualities qualities: Set<IntervalQuality>) -> [IntervalType] {
        allIntervals.filter { qualities.contains($0.quality) }
    }
    
    /// Get only simple intervals (within one octave)
    func simpleIntervals(for difficulty: IntervalDifficulty) -> [IntervalType] {
        intervals(for: difficulty).filter { $0.semitones <= 12 }
    }
    
    /// Get only compound intervals (beyond one octave)
    func compoundIntervals() -> [IntervalType] {
        allIntervals.filter { $0.semitones > 12 }
    }
    
    /// Get interval by semitone count
    func interval(forSemitones semitones: Int) -> IntervalType? {
        allIntervals.first { $0.semitones == semitones }
    }
    
    // MARK: - Random Generation
    
    /// Get a random interval with optional filters
    func getRandomInterval(
        difficulty: IntervalDifficulty = .intermediate,
        rootNote: Note? = nil,
        direction: IntervalDirection = .ascending,
        qualities: Set<IntervalQuality>? = nil
    ) -> Interval {
        var candidates = intervals(for: difficulty)
        
        // Filter by qualities if specified
        if let qualities = qualities, !qualities.isEmpty {
            candidates = candidates.filter { qualities.contains($0.quality) }
        }
        
        // Ensure we have candidates
        if candidates.isEmpty {
            candidates = [allIntervals[0]]
        }
        
        let intervalType = candidates.randomElement()!
        let root = rootNote ?? Note.allNotes.filter { !$0.isSharp || $0.name.contains("#") }.randomElement()!
        
        // Determine actual direction (resolve "both" to a specific direction)
        let actualDirection: IntervalDirection
        if direction == .both {
            actualDirection = Bool.random() ? .ascending : .descending
        } else {
            actualDirection = direction
        }
        
        return Interval(
            rootNote: root,
            intervalType: intervalType,
            direction: actualDirection
        )
    }
    
    // MARK: - Song References (for learning)
    
    /// Famous song references for each interval (ascending)
    static let ascendingSongReferences: [Int: String] = [
        0: "Same note",
        1: "Jaws theme",
        2: "Happy Birthday (first two notes)",
        3: "Greensleeves",
        4: "Oh When The Saints",
        5: "Here Comes The Bride",
        6: "The Simpsons theme",
        7: "Star Wars theme",
        8: "Love Story theme",
        9: "My Bonnie Lies Over The Ocean",
        10: "Somewhere (West Side Story)",
        11: "Take On Me (chorus)",
        12: "Somewhere Over The Rainbow"
    ]
    
    /// Get song reference for an interval
    func songReference(for intervalType: IntervalType, direction: IntervalDirection = .ascending) -> String? {
        // Only provide ascending references for now
        guard direction == .ascending else { return nil }
        return IntervalDatabase.ascendingSongReferences[intervalType.semitones]
    }
}
