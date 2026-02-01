import Foundation
import SwiftUI

// MARK: - Chord Drill Configuration

/// Configuration for a chord drill session
struct ChordDrillConfig: Equatable, Codable, Hashable {
    var chordTypes: Set<String>          // Empty = all types
    var keyDifficulty: KeyDifficulty
    var questionTypes: Set<QuestionType>
    var difficulty: ChordType.ChordDifficulty
    var questionCount: Int
    var audioEnabled: Bool
    var customKeys: Set<String>?         // Used when keyDifficulty == .custom (key names like "C", "G", etc.)
    
    init(
        chordTypes: Set<String> = [],
        keyDifficulty: KeyDifficulty = .all,
        questionTypes: Set<QuestionType> = [.singleTone, .allTones],
        difficulty: ChordType.ChordDifficulty = .beginner,
        questionCount: Int = 10,
        audioEnabled: Bool = true,
        customKeys: Set<String>? = nil
    ) {
        self.chordTypes = chordTypes
        self.keyDifficulty = keyDifficulty
        self.questionTypes = questionTypes
        self.difficulty = difficulty
        self.questionCount = questionCount
        self.audioEnabled = audioEnabled
        self.customKeys = customKeys
    }
    
    static let `default` = ChordDrillConfig(
        chordTypes: [],
        keyDifficulty: .all,
        questionTypes: [.singleTone, .allTones],
        difficulty: .beginner,
        questionCount: 10,
        audioEnabled: true
    )
    
    static func fromPreset(_ preset: ChordDrillPreset) -> ChordDrillConfig {
        switch preset {
        case .basicTriads:
            return ChordDrillConfig(
                chordTypes: ["", "m", "dim", "aug", "sus2", "sus4"],  // All triads
                keyDifficulty: .easy,
                questionTypes: [.allTones],
                difficulty: .beginner,
                questionCount: 10,
                audioEnabled: true
            )
        case .seventhAndSixthChords:
            return ChordDrillConfig(
                chordTypes: ["7", "maj7", "m7", "m7b5", "dim7", "m(maj7)", "7#5", "maj6", "m6"],  // All 7th/6th chords
                keyDifficulty: .medium,
                questionTypes: [.allTones],
                difficulty: .intermediate,
                questionCount: 10,
                audioEnabled: true
            )
        case .fullWorkout:
            return ChordDrillConfig(
                chordTypes: [],  // All types
                keyDifficulty: .all,
                questionTypes: [.singleTone, .allTones, .auralQuality, .auralSpelling],
                difficulty: .advanced,
                questionCount: 15,
                audioEnabled: true
            )
        }
    }
}

// MARK: - Chord Question

/// A single question in a chord drill
struct ChordDrillQuestion: Identifiable, Equatable {
    let id = UUID()
    let chord: Chord
    let questionType: QuestionType
    let targetTone: ChordTone?  // For single tone questions
    
    var correctAnswer: Set<Note> {
        switch questionType {
        case .singleTone:
            if let tone = targetTone,
               let note = chord.getChordTone(by: tone.degree, isAltered: tone.isAltered) {
                return [note]
            }
            return []
        case .allTones, .auralSpelling:
            return Set(chord.chordTones)
        case .auralQuality:
            return []  // Answer is ChordType, not notes
        }
    }
    
    static func == (lhs: ChordDrillQuestion, rhs: ChordDrillQuestion) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Chord Answer Result

/// Result of answering a chord question
struct ChordAnswerResult {
    let question: ChordDrillQuestion
    let userNotes: Set<Note>
    let userChordType: ChordType?
    let isCorrect: Bool
    let responseTime: TimeInterval
    
    var missedNotes: Set<Note> {
        question.correctAnswer.subtracting(userNotes)
    }
    
    var extraNotes: Set<Note> {
        userNotes.subtracting(question.correctAnswer)
    }
}

// MARK: - Chord Drill Session

/// Results of a completed chord drill session
struct ChordDrillSession: Identifiable {
    let id = UUID()
    let config: ChordDrillConfig
    let startTime: Date
    let endTime: Date
    let results: [ChordAnswerResult]
    
    var totalQuestions: Int { results.count }
    var correctCount: Int { results.filter(\.isCorrect).count }
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions)
    }
    var duration: TimeInterval { endTime.timeIntervalSince(startTime) }
    
    var missedItems: [MissedItem] {
        results.filter { !$0.isCorrect }.map { result in
            MissedItem(
                question: result.question.chord.displayName,
                userAnswer: result.userNotes.map(\.name).sorted().joined(separator: "-"),
                correctAnswer: result.question.correctAnswer.map(\.name).sorted().joined(separator: "-"),
                category: result.question.questionType.rawValue
            )
        }
    }
    
    func toDrillSessionResult() -> DrillSessionResult {
        DrillSessionResult(
            drillType: .chordDrill,
            startTime: startTime,
            endTime: endTime,
            totalQuestions: totalQuestions,
            correctAnswers: correctCount,
            missedItems: missedItems
        )
    }
}

// MARK: - Chord Drill Game

/// Main game logic for chord drilling
/// Per DESIGN.md Section 12.2
@MainActor
class ChordDrillGame: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var state: DrillState = .setup
    @Published private(set) var config: ChordDrillConfig = .default
    @Published private(set) var questions: [ChordDrillQuestion] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var results: [ChordAnswerResult] = []
    @Published private(set) var session: ChordDrillSession?
    
    // Feedback state
    @Published var showingFeedback = false
    @Published var lastAnswerCorrect = false
    
    // MARK: - Private Properties
    
    private var startTime: Date?
    private var questionStartTime: Date?
    private let database = JazzChordDatabase.shared
    
    // MARK: - Computed Properties
    
    var currentQuestion: ChordDrillQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }
    
    var correctCount: Int {
        results.filter(\.isCorrect).count
    }
    
    var accuracy: Double {
        guard !results.isEmpty else { return 0 }
        return Double(correctCount) / Double(results.count)
    }
    
    var isLastQuestion: Bool {
        currentIndex >= questions.count - 1
    }
    
    // MARK: - Game Control
    
    /// Start a new drill session with the given configuration
    func startDrill(config: ChordDrillConfig) {
        self.config = config
        self.questions = generateQuestions(config: config)
        self.currentIndex = 0
        self.results = []
        self.session = nil
        self.showingFeedback = false
        self.startTime = Date()
        self.questionStartTime = Date()
        self.state = .active
    }
    
    /// Start a drill with a preset
    func startDrill(preset: ChordDrillPreset) {
        startDrill(config: .fromPreset(preset))
    }
    
    /// Submit an answer for the current question (note-based)
    func submitAnswer(notes: Set<Note>) {
        guard let question = currentQuestion,
              let qStart = questionStartTime else { return }
        
        let responseTime = Date().timeIntervalSince(qStart)
        let isCorrect = checkAnswer(notes: notes, for: question)
        
        let result = ChordAnswerResult(
            question: question,
            userNotes: notes,
            userChordType: nil,
            isCorrect: isCorrect,
            responseTime: responseTime
        )
        
        results.append(result)
        lastAnswerCorrect = isCorrect
        showingFeedback = true
    }
    
    /// Submit an answer for aural quality questions (chord type based)
    func submitAnswer(chordType: ChordType) {
        guard let question = currentQuestion,
              let qStart = questionStartTime else { return }
        
        let responseTime = Date().timeIntervalSince(qStart)
        let isCorrect = chordType.id == question.chord.chordType.id
        
        let result = ChordAnswerResult(
            question: question,
            userNotes: [],
            userChordType: chordType,
            isCorrect: isCorrect,
            responseTime: responseTime
        )
        
        results.append(result)
        lastAnswerCorrect = isCorrect
        showingFeedback = true
    }
    
    /// Move to the next question or finish the drill
    func nextQuestion() {
        showingFeedback = false
        
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            questionStartTime = Date()
        } else {
            finishDrill()
        }
    }
    
    /// Reset to setup state
    func reset() {
        state = .setup
        questions = []
        currentIndex = 0
        results = []
        session = nil
        showingFeedback = false
        startTime = nil
        questionStartTime = nil
    }
    
    /// Quit the current drill (saves progress for answered questions)
    func quit() {
        if !results.isEmpty {
            finishDrill()
        } else {
            reset()
        }
    }
    
    // MARK: - Private Methods
    
    private func finishDrill() {
        guard let start = startTime else { return }
        
        session = ChordDrillSession(
            config: config,
            startTime: start,
            endTime: Date(),
            results: results
        )
        
        state = .results
        // Clear currentIndex to prevent currentQuestion from returning a value
        currentIndex = questions.count
    }
    
    private func generateQuestions(config: ChordDrillConfig) -> [ChordDrillQuestion] {
        var questions: [ChordDrillQuestion] = []
        
        // Get available chord types
        let availableChordTypes: [ChordType]
        if config.chordTypes.isEmpty {
            availableChordTypes = database.chordTypes.filter { $0.difficulty == config.difficulty || config.difficulty == .advanced }
        } else {
            availableChordTypes = database.chordTypes.filter { config.chordTypes.contains($0.symbol) }
        }
        
        guard !availableChordTypes.isEmpty else { return [] }
        
        // Get available root notes based on key difficulty
        let availableRoots = getAvailableRoots(for: config.keyDifficulty)
        let questionTypes = Array(config.questionTypes)
        
        guard !questionTypes.isEmpty else { return [] }
        
        for _ in 0..<config.questionCount {
            // Random root and chord type
            let root = availableRoots.randomElement() ?? Note(name: "C", midiNumber: 60, isSharp: false)
            let chordType = availableChordTypes.randomElement()!
            let chord = Chord(root: root, chordType: chordType)
            
            // Random question type
            let questionType = questionTypes.randomElement()!
            
            // For single tone questions, pick a random tone from the chord
            var targetTone: ChordTone? = nil
            if questionType == .singleTone {
                targetTone = chordType.chordTones.randomElement()
            }
            
            let question = ChordDrillQuestion(
                chord: chord,
                questionType: questionType,
                targetTone: targetTone
            )
            questions.append(question)
        }
        
        return questions
    }
    
    private func getAvailableRoots(for difficulty: KeyDifficulty) -> [Note] {
        let allRoots: [(String, Int, Bool)] = [
            ("C", 60, false), ("Db", 61, false), ("D", 62, false),
            ("Eb", 63, false), ("E", 64, false), ("F", 65, false),
            ("F#", 66, true), ("G", 67, false), ("Ab", 68, false),
            ("A", 69, false), ("Bb", 70, false), ("B", 71, false)
        ]
        
        let filteredNames: Set<String>
        switch difficulty {
        case .easy:
            filteredNames = ["C", "F", "G", "Bb"]
        case .medium:
            filteredNames = ["C", "Db", "D", "Eb", "F", "G", "Bb", "A"]
        case .hard:
            filteredNames = ["Db", "F#", "Ab", "B", "E"]
        case .expert:
            filteredNames = ["F#"]  // 6 accidentals
        case .all:
            filteredNames = Set(allRoots.map { $0.0 })
        case .custom:
            // For custom, use customKeys from config if available, otherwise fall back to all
            if let customKeys = config.customKeys, !customKeys.isEmpty {
                filteredNames = customKeys
            } else {
                filteredNames = Set(allRoots.map { $0.0 })
            }
        }
        
        return allRoots
            .filter { filteredNames.contains($0.0) }
            .map { Note(name: $0.0, midiNumber: $0.1, isSharp: $0.2) }
    }
    
    private func checkAnswer(notes: Set<Note>, for question: ChordDrillQuestion) -> Bool {
        let correctNotes = question.correctAnswer
        
        // Normalize both sets to compare only pitch classes
        let normalizedUser = Set(notes.map { $0.midiNumber % 12 })
        let normalizedCorrect = Set(correctNotes.map { $0.midiNumber % 12 })
        
        return normalizedUser == normalizedCorrect
    }
}

// MARK: - Answer Choices for Aural Questions

extension ChordDrillGame {
    /// Get multiple choice options for aural quality questions
    func getAnswerChoices(for question: ChordDrillQuestion, count: Int = 4) -> [ChordType] {
        let correctType = question.chord.chordType
        var choices: [ChordType] = [correctType]
        
        // Get similar chord types for distractors
        let allTypes = database.chordTypes.filter { $0.difficulty == correctType.difficulty }
        let distractors = allTypes.filter { $0.id != correctType.id }.shuffled().prefix(count - 1)
        
        choices.append(contentsOf: distractors)
        return choices.shuffled()
    }
}
