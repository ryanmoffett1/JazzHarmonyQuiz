import Foundation

// MARK: - Note and Chord Tone Models
struct Note: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    let midiNumber: Int
    let isSharp: Bool
    
    static let allNotes: [Note] = [
        Note(name: "C", midiNumber: 60, isSharp: false),
        Note(name: "C#", midiNumber: 61, isSharp: true),
        Note(name: "Db", midiNumber: 61, isSharp: false),
        Note(name: "D", midiNumber: 62, isSharp: false),
        Note(name: "D#", midiNumber: 63, isSharp: true),
        Note(name: "Eb", midiNumber: 63, isSharp: false),
        Note(name: "E", midiNumber: 64, isSharp: false),
        Note(name: "F", midiNumber: 65, isSharp: false),
        Note(name: "F#", midiNumber: 66, isSharp: true),
        Note(name: "Gb", midiNumber: 66, isSharp: false),
        Note(name: "G", midiNumber: 67, isSharp: false),
        Note(name: "G#", midiNumber: 68, isSharp: true),
        Note(name: "Ab", midiNumber: 68, isSharp: false),
        Note(name: "A", midiNumber: 69, isSharp: false),
        Note(name: "A#", midiNumber: 70, isSharp: true),
        Note(name: "Bb", midiNumber: 70, isSharp: false),
        Note(name: "B", midiNumber: 71, isSharp: false)
    ]
    
    static func noteFromMidi(_ midiNumber: Int) -> Note? {
        // Handle octave wrapping - map to the base octave (60-71)
        let baseMidiNumber = ((midiNumber - 60) % 12) + 60
        return allNotes.first { $0.midiNumber == baseMidiNumber }
    }
    
}

struct ChordTone: Identifiable, Hashable, Codable {
    let id = UUID()
    let degree: Int
    let name: String
    let semitonesFromRoot: Int
    let isAltered: Bool
    
    static let allTones: [ChordTone] = [
        ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
        ChordTone(degree: 2, name: "2nd", semitonesFromRoot: 2, isAltered: false),
        ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
        ChordTone(degree: 4, name: "4th", semitonesFromRoot: 5, isAltered: false),
        ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
        ChordTone(degree: 6, name: "6th", semitonesFromRoot: 9, isAltered: false),
        ChordTone(degree: 7, name: "7th", semitonesFromRoot: 11, isAltered: false),
        ChordTone(degree: 9, name: "9th", semitonesFromRoot: 2, isAltered: false),
        ChordTone(degree: 11, name: "11th", semitonesFromRoot: 5, isAltered: false),
        ChordTone(degree: 13, name: "13th", semitonesFromRoot: 9, isAltered: false),
        
        // Altered tones
        ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true),
        ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true),
        ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true),
        ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true),
        ChordTone(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true),
        ChordTone(degree: 6, name: "b13", semitonesFromRoot: 8, isAltered: true),
        ChordTone(degree: 6, name: "#13", semitonesFromRoot: 10, isAltered: true),
        ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
    ]
}

// MARK: - Chord Type Model
struct ChordType: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let symbol: String
    let chordTones: [ChordTone]
    let difficulty: ChordDifficulty
    
    init(name: String, symbol: String, chordTones: [ChordTone], difficulty: ChordDifficulty) {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
        self.chordTones = chordTones
        self.difficulty = difficulty
    }
    
    enum ChordDifficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
    }
}

// MARK: - Chord Model
struct Chord: Identifiable, Hashable, Codable {
    let id = UUID()
    let root: Note
    let chordType: ChordType
    let chordTones: [Note]
    
    var displayName: String {
        return "\(root.name)\(chordType.symbol)"
    }
    
    var fullName: String {
        return "\(root.name) \(chordType.name)"
    }
    
    init(root: Note, chordType: ChordType) {
        self.root = root
        self.chordType = chordType
        
        // Calculate chord tones based on root and chord type
        var tones: [Note] = []
        for chordTone in chordType.chordTones {
            let midiNumber = root.midiNumber + chordTone.semitonesFromRoot
            if let note = Note.noteFromMidi(midiNumber) {
                tones.append(note)
            }
        }
        self.chordTones = tones
    }
    
    func getChordTone(by degree: Int, isAltered: Bool = false) -> Note? {
        let targetTone = ChordTone.allTones.first { 
            $0.degree == degree && $0.isAltered == isAltered 
        }
        
        guard let tone = targetTone else { return nil }
        
        let midiNumber = root.midiNumber + tone.semitonesFromRoot
        return Note.noteFromMidi(midiNumber)
    }
    
    func getChordTone(by name: String) -> Note? {
        let targetTone = ChordTone.allTones.first { $0.name == name }
        
        guard let tone = targetTone else { return nil }
        
        let midiNumber = root.midiNumber + tone.semitonesFromRoot
        return Note.noteFromMidi(midiNumber)
    }
}

// MARK: - Question Types
enum QuestionType: String, CaseIterable, Codable, Equatable {
    case singleTone = "Single Tone"
    case allTones = "All Tones"
    case chordSpelling = "Chord Spelling"
    
    var description: String {
        switch self {
        case .singleTone:
            return "Identify a specific chord tone"
        case .allTones:
            return "Play all chord tones"
        case .chordSpelling:
            return "Spell the entire chord"
        }
    }
}

// MARK: - Quiz Question Model
struct QuizQuestion: Identifiable, Codable, Equatable {
    let id = UUID()
    let chord: Chord
    let questionType: QuestionType
    let targetTone: ChordTone?
    let correctAnswer: [Note]
    let timeLimit: TimeInterval
    
    init(chord: Chord, questionType: QuestionType, targetTone: ChordTone? = nil) {
        self.chord = chord
        self.questionType = questionType
        self.targetTone = targetTone
        
        switch questionType {
        case .singleTone:
            if let tone = targetTone {
                self.correctAnswer = [chord.getChordTone(by: tone.name) ?? chord.root]
            } else {
                self.correctAnswer = [chord.root]
            }
        case .allTones:
            self.correctAnswer = chord.chordTones
        case .chordSpelling:
            self.correctAnswer = chord.chordTones
        }
        
        self.timeLimit = 30.0 // 30 seconds default
    }
}

// MARK: - Quiz Result Model
struct QuizResult: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let totalTime: TimeInterval
    let questions: [QuizQuestion]
    let userAnswers: [String: [Note]] // Question ID to user's answer
    let isCorrect: [String: Bool] // Question ID to correctness
    
    init(date: Date, totalQuestions: Int, correctAnswers: Int, totalTime: TimeInterval, questions: [QuizQuestion], userAnswers: [UUID: [Note]], isCorrect: [UUID: Bool]) {
        self.id = UUID()
        self.date = date
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.totalTime = totalTime
        self.questions = questions
        self.userAnswers = Dictionary(uniqueKeysWithValues: userAnswers.map { ($0.key.uuidString, $0.value) })
        self.isCorrect = Dictionary(uniqueKeysWithValues: isCorrect.map { ($0.key.uuidString, $0.value) })
    }
    
    var accuracy: Double {
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var averageTimePerQuestion: TimeInterval {
        return totalTime / Double(totalQuestions)
    }
    
    var score: Int {
        return Int(accuracy * 100)
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, date, totalQuestions, correctAnswers, totalTime, questions, userAnswers, isCorrect
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.date = try container.decode(Date.self, forKey: .date)
        self.totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        self.correctAnswers = try container.decode(Int.self, forKey: .correctAnswers)
        self.totalTime = try container.decode(TimeInterval.self, forKey: .totalTime)
        self.questions = try container.decode([QuizQuestion].self, forKey: .questions)
        self.userAnswers = try container.decode([String: [Note]].self, forKey: .userAnswers)
        self.isCorrect = try container.decode([String: Bool].self, forKey: .isCorrect)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(totalQuestions, forKey: .totalQuestions)
        try container.encode(correctAnswers, forKey: .correctAnswers)
        try container.encode(totalTime, forKey: .totalTime)
        try container.encode(questions, forKey: .questions)
        try container.encode(userAnswers, forKey: .userAnswers)
        try container.encode(isCorrect, forKey: .isCorrect)
    }
}
