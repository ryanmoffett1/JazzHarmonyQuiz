import XCTest
@testable import JazzHarmonyQuiz

final class ChordModelTests: XCTestCase {
    
    // MARK: - Note Tests
    
    func testNoteEquality() {
        let cSharp = Note(name: "C#", midiNumber: 61, isSharp: true)
        let dFlat = Note(name: "Db", midiNumber: 61, isSharp: false)
        
        // Should be equal because they have the same MIDI number (enharmonic equivalents)
        XCTAssertEqual(cSharp, dFlat)
    }
    
    func testNoteFromMidiWithSharps() {
        let note = Note.noteFromMidi(61, preferSharps: true)
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "C#")
        XCTAssertTrue(note?.isSharp ?? false)
    }
    
    func testNoteFromMidiWithFlats() {
        let note = Note.noteFromMidi(61, preferSharps: false)
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "Db")
        XCTAssertFalse(note?.isSharp ?? true)
    }
    
    func testNoteFromMidiWithNaturalNote() {
        let note = Note.noteFromMidi(60, preferSharps: true)
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "C")
        XCTAssertFalse(note?.isSharp ?? true)
    }
    
    func testNoteFromMidiWithOctaveWrapping() {
        // Test octave wrapping - MIDI 72 should map to same note as 60 (C)
        let note = Note.noteFromMidi(72, preferSharps: true)
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.midiNumber, 60)
        XCTAssertEqual(note?.name, "C")
    }
    
    func testAllNotesCount() {
        // Should have all 12 notes including enharmonic equivalents
        XCTAssertEqual(Note.allNotes.count, 17)
    }
    
    // MARK: - ChordTone Tests
    
    func testChordToneDefinitions() {
        let root = ChordTone.allTones.first { $0.name == "Root" }
        XCTAssertNotNil(root)
        XCTAssertEqual(root?.degree, 1)
        XCTAssertEqual(root?.semitonesFromRoot, 0)
        XCTAssertFalse(root?.isAltered ?? true)
        
        let flatNine = ChordTone.allTones.first { $0.name == "b9" }
        XCTAssertNotNil(flatNine)
        XCTAssertEqual(flatNine?.degree, 2)
        XCTAssertEqual(flatNine?.semitonesFromRoot, 1)
        XCTAssertTrue(flatNine?.isAltered ?? false)
    }
    
    // MARK: - ChordType Tests
    
    func testMajorTriadStructure() {
        let majorTriad = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        XCTAssertEqual(majorTriad.name, "Major Triad")
        XCTAssertEqual(majorTriad.symbol, "")
        XCTAssertEqual(majorTriad.chordTones.count, 3)
        XCTAssertEqual(majorTriad.difficulty, .beginner)
    }
    
    func testDominant7thStructure() {
        let dom7 = ChordType(
            name: "Dominant 7th",
            symbol: "7",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
                ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
            ],
            difficulty: .beginner
        )
        
        XCTAssertEqual(dom7.chordTones.count, 4)
        XCTAssertTrue(dom7.chordTones.last?.isAltered ?? false)
    }
    
    // MARK: - Chord Tests
    
    func testCMajorTriadConstruction() {
        let cNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorTriad = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let chord = Chord(root: cNote, chordType: majorTriad)
        
        XCTAssertEqual(chord.displayName, "C")
        XCTAssertEqual(chord.fullName, "C Major Triad")
        XCTAssertEqual(chord.chordTones.count, 3)
        XCTAssertEqual(chord.chordTones[0].midiNumber, 60) // C
        XCTAssertEqual(chord.chordTones[1].midiNumber, 64) // E
        XCTAssertEqual(chord.chordTones[2].midiNumber, 67) // G
    }
    
    func testChordDisplayName() {
        let dNote = Note(name: "D", midiNumber: 62, isSharp: false)
        let minorTriad = ChordType(
            name: "Minor Triad",
            symbol: "m",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let chord = Chord(root: dNote, chordType: minorTriad)
        
        XCTAssertEqual(chord.displayName, "Dm")
        XCTAssertEqual(chord.fullName, "D Minor Triad")
    }
    
    func testChordTonalityPreference() {
        // F# major chord should use sharps
        let fSharp = Note(name: "F#", midiNumber: 66, isSharp: true)
        let majorTriad = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let chord = Chord(root: fSharp, chordType: majorTriad)
        
        XCTAssertEqual(chord.chordTones.count, 3)
        // Should prefer sharps for F# root
        XCTAssertEqual(chord.chordTones[1].name, "A#") // Major 3rd of F#
    }
    
    func testGetChordToneByDegree() {
        let cNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let dom7 = ChordType(
            name: "Dominant 7th",
            symbol: "7",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
                ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
            ],
            difficulty: .beginner
        )
        
        let chord = Chord(root: cNote, chordType: dom7)
        
        let root = chord.getChordTone(by: 1, isAltered: false)
        XCTAssertNotNil(root)
        XCTAssertEqual(root?.midiNumber, 60)
        
        let seventh = chord.getChordTone(by: 7, isAltered: true)
        XCTAssertNotNil(seventh)
        XCTAssertEqual(seventh?.midiNumber, 70) // Bb
    }
    
    func testGetChordToneByName() {
        let cNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let dom7 = ChordType(
            name: "Dominant 7th",
            symbol: "7",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
                ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
            ],
            difficulty: .beginner
        )
        
        let chord = Chord(root: cNote, chordType: dom7)
        
        let fifth = chord.getChordTone(by: "5th")
        XCTAssertNotNil(fifth)
        XCTAssertEqual(fifth?.midiNumber, 67) // G
        
        let flatSeventh = chord.getChordTone(by: "b7")
        XCTAssertNotNil(flatSeventh)
        XCTAssertEqual(flatSeventh?.midiNumber, 70) // Bb
    }
    
    // MARK: - QuizQuestion Tests
    
    func testSingleToneQuestionCreation() {
        let cNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorTriad = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        let chord = Chord(root: cNote, chordType: majorTriad)
        let targetTone = ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false)
        
        let question = QuizQuestion(chord: chord, questionType: .singleTone, targetTone: targetTone)
        
        XCTAssertEqual(question.questionType, .singleTone)
        XCTAssertNotNil(question.targetTone)
        XCTAssertEqual(question.correctAnswer.count, 1)
        XCTAssertEqual(question.timeLimit, 30.0)
    }
    
    func testAllTonesQuestionCreation() {
        let cNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorTriad = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        let chord = Chord(root: cNote, chordType: majorTriad)
        
        let question = QuizQuestion(chord: chord, questionType: .allTones)
        
        XCTAssertEqual(question.questionType, .allTones)
        XCTAssertNil(question.targetTone)
        XCTAssertEqual(question.correctAnswer.count, 3)
        XCTAssertEqual(question.correctAnswer, chord.chordTones)
    }
    
    func testChordSpellingQuestionCreation() {
        let dNote = Note(name: "D", midiNumber: 62, isSharp: false)
        let dom7 = ChordType(
            name: "Dominant 7th",
            symbol: "7",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
                ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
            ],
            difficulty: .beginner
        )
        let chord = Chord(root: dNote, chordType: dom7)
        
        let question = QuizQuestion(chord: chord, questionType: .allTones)
        
        XCTAssertEqual(question.questionType, .allTones)
        XCTAssertNil(question.targetTone)
        XCTAssertEqual(question.correctAnswer.count, 4)
        XCTAssertEqual(question.correctAnswer, chord.chordTones)
    }
    
    // MARK: - QuizResult Tests
    
    func testQuizResultCreation() {
        let cNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorTriad = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        let chord = Chord(root: cNote, chordType: majorTriad)
        let question = QuizQuestion(chord: chord, questionType: .allTones)
        
        let userAnswers = [question.id: chord.chordTones]
        let isCorrect = [question.id: true]
        
        let result = QuizResult(
            date: Date(),
            totalQuestions: 1,
            correctAnswers: 1,
            totalTime: 10.0,
            questions: [question],
            userAnswers: userAnswers,
            isCorrect: isCorrect
        )
        
        XCTAssertEqual(result.totalQuestions, 1)
        XCTAssertEqual(result.correctAnswers, 1)
        XCTAssertEqual(result.accuracy, 1.0)
        XCTAssertEqual(result.score, 100)
        XCTAssertEqual(result.averageTimePerQuestion, 10.0)
    }
    
    func testQuizResultAccuracy() {
        let cNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorTriad = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        let chord = Chord(root: cNote, chordType: majorTriad)
        let question = QuizQuestion(chord: chord, questionType: .allTones)
        
        let userAnswers = [question.id: chord.chordTones]
        let isCorrect = [question.id: true]
        
        let result = QuizResult(
            date: Date(),
            totalQuestions: 5,
            correctAnswers: 3,
            totalTime: 50.0,
            questions: [question],
            userAnswers: userAnswers,
            isCorrect: isCorrect
        )
        
        XCTAssertEqual(result.accuracy, 0.6)
        XCTAssertEqual(result.score, 60)
    }
    
    func testQuizResultEncodingDecoding() throws {
        let cNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorTriad = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        let chord = Chord(root: cNote, chordType: majorTriad)
        let question = QuizQuestion(chord: chord, questionType: .allTones)
        
        let userAnswers = [question.id: chord.chordTones]
        let isCorrect = [question.id: true]
        
        let result = QuizResult(
            date: Date(),
            totalQuestions: 1,
            correctAnswers: 1,
            totalTime: 10.0,
            questions: [question],
            userAnswers: userAnswers,
            isCorrect: isCorrect
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(result)
        
        let decoder = JSONDecoder()
        let decodedResult = try decoder.decode(QuizResult.self, from: data)
        
        XCTAssertEqual(decodedResult.totalQuestions, result.totalQuestions)
        XCTAssertEqual(decodedResult.correctAnswers, result.correctAnswers)
        XCTAssertEqual(decodedResult.accuracy, result.accuracy)
    }
}
