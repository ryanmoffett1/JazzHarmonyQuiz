import Foundation
import SwiftUI

class CadenceGame: ObservableObject {
    // MARK: - Published Quiz State
    @Published var currentQuestion: CadenceQuestion?
    @Published var currentQuestionIndex: Int = 0
    @Published var totalQuestions: Int = 10
    @Published var questions: [CadenceQuestion] = []
    @Published var userAnswers: [UUID: [[Note]]] = [:] // Question ID -> array of 3 chord spellings
    @Published var questionStartTime: Date?
    @Published var totalQuizTime: TimeInterval = 0
    @Published var isQuizActive: Bool = false
    @Published var isQuizCompleted: Bool = false
    @Published var currentResult: CadenceResult?
    @Published var selectedCadenceType: CadenceType = .major
    
    // MARK: - Phase 1 Enhancement Properties
    @Published var selectedDrillMode: CadenceDrillMode = .fullProgression
    @Published var selectedKeyDifficulty: KeyDifficulty = .all
    
    // MARK: - Phase 2 Enhancement Properties
    @Published var useMixedCadences: Bool = false
    @Published var selectedCadenceTypes: Set<CadenceType> = [.major]  // For mixed mode
    
    // MARK: - Phase 3 Enhancement Properties
    @Published var useExtendedVChords: Bool = false
    @Published var selectedExtendedVChord: ExtendedVChordOption = .basic
    @Published var selectedCommonTonePair: CommonTonePair = .iiToV  // For common tones mode
    
    // MARK: - Phase 4: Statistics
    @Published var lifetimeStats: CadenceLifetimeStats = CadenceLifetimeStats()
    @Published var lastQuizSettings: LastQuizSettings?
    
    // MARK: - Rating & Level System
    @Published var lastRatingChange: Int = 0
    @Published var didRankUp: Bool = false
    @Published var previousLevel: Int?
    
    // Shared player stats (rating, streaks, achievements)
    var playerStats: PlayerStats { PlayerStats.shared }
    
    // MARK: - Streak Tracking
    @Published var currentStreak: Int = 0
    @Published var lastPracticeDate: Date?
    
    // MARK: - Hint System
    @Published var hintsUsedThisQuestion: Int = 0
    @Published var totalHintsUsed: Int = 0
    @Published var currentHintLevel: Int = 0  // 0 = no hint, 1 = formula, 2 = intervals, 3 = first note
    
    private var quizStartTime: Date?
    private var timer: Timer?
    
    // MARK: - UserDefaults Keys
    private let streakKey = "JazzHarmonyCadenceStreak"
    private let lastPracticeDateKey = "JazzHarmonyCadenceLastPracticeDate"
    private let lifetimeStatsKey = "JazzHarmonyCadenceLifetimeStats"
    private let lastQuizSettingsKey = "JazzHarmonyCadenceLastQuizSettings"

    // MARK: - Quiz Management

    func startNewQuiz(numberOfQuestions: Int, cadenceType: CadenceType) {
        startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            cadenceType: cadenceType,
            drillMode: .fullProgression,
            keyDifficulty: .all
        )
    }
    
    func startNewQuiz(
        numberOfQuestions: Int,
        cadenceType: CadenceType,
        drillMode: CadenceDrillMode,
        keyDifficulty: KeyDifficulty
    ) {
        totalQuestions = numberOfQuestions
        selectedCadenceType = cadenceType
        selectedDrillMode = drillMode
        selectedKeyDifficulty = keyDifficulty

        generateQuestions()
        currentQuestionIndex = 0
        userAnswers = [:]
        totalQuizTime = 0
        isQuizActive = true
        isQuizCompleted = false
        currentResult = nil
        quizStartTime = Date()
        
        // Reset hint tracking
        hintsUsedThisQuestion = 0
        totalHintsUsed = 0
        currentHintLevel = 0
        
        // Update streak
        updateStreak()

        if !questions.isEmpty {
            currentQuestion = questions[0]
            questionStartTime = Date()
        }
    }

    private func generateQuestions() {
        questions = []

        // Use roots based on selected key difficulty
        let possibleRoots = selectedKeyDifficulty.availableRoots
        
        // Determine which cadence types to use
        let cadenceTypesToUse: [CadenceType]
        if useMixedCadences && !selectedCadenceTypes.isEmpty {
            cadenceTypesToUse = Array(selectedCadenceTypes)
        } else {
            cadenceTypesToUse = [selectedCadenceType]
        }

        for _ in 0..<totalQuestions {
            // Pick a random key from available roots
            let key = possibleRoots.randomElement()!
            
            // Pick a cadence type (random if mixed mode)
            let cadenceType = cadenceTypesToUse.randomElement() ?? selectedCadenceType

            // Create cadence progression with extended V chord if enabled
            let extendedV = useExtendedVChords ? selectedExtendedVChord : nil
            let cadence = CadenceProgression(key: key, cadenceType: cadenceType, extendedVChord: extendedV)

            // Create question based on drill mode
            let question: CadenceQuestion
            if selectedDrillMode == .commonTones {
                // For common tones mode, create a common tones question
                let pair: CommonTonePair
                if selectedCommonTonePair == .random {
                    pair = Bool.random() ? .iiToV : .vToI
                } else {
                    pair = selectedCommonTonePair
                }
                question = CadenceQuestion(cadence: cadence, commonTonePair: pair)
            } else if selectedDrillMode == .guideTones {
                // For guide tones mode
                question = CadenceQuestion(cadence: cadence, guideTonesMode: true)
            } else if selectedDrillMode == .resolutionTargets {
                // For resolution targets mode, generate resolution pairs
                let pairs = generateResolutionPairs(for: cadence)
                let randomIndex = Int.random(in: 0..<pairs.count)
                question = CadenceQuestion(cadence: cadence, resolutionPairs: pairs, currentIndex: randomIndex)
            } else {
                question = CadenceQuestion(
                    cadence: cadence,
                    drillMode: selectedDrillMode,
                    isolatedPosition: nil  // isolatedChord mode removed
                )
            }
            questions.append(question)
        }
    }

    func submitAnswer(_ chordSpellings: [[Note]]) {
        guard let question = currentQuestion else { return }

        // Record the answer
        userAnswers[question.id] = chordSpellings

        // Calculate time for this question
        if let startTime = questionStartTime {
            let questionTime = Date().timeIntervalSince(startTime)
            totalQuizTime += questionTime
        }

        // Move to next question
        nextQuestion()
    }

    private func nextQuestion() {
        currentQuestionIndex += 1
        
        // Reset hint tracking for new question
        hintsUsedThisQuestion = 0
        currentHintLevel = 0

        if currentQuestionIndex < questions.count {
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        } else {
            finishQuiz()
        }
    }

    private func finishQuiz() {
        isQuizActive = false

        // Calculate final results BEFORE setting isQuizCompleted
        // This ensures currentResult is populated when the view transitions
        var correctAnswers = 0
        var questionResults: [UUID: Bool] = [:]

        for question in questions {
            let userAnswer = userAnswers[question.id] ?? [[], [], []]
            let isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
            questionResults[question.id] = isCorrect

            if isCorrect {
                correctAnswers += 1
            }
        }

        currentResult = CadenceResult(
            date: Date(),
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            totalTime: totalQuizTime,
            questions: questions,
            userAnswers: userAnswers,
            isCorrect: questionResults,
            cadenceType: selectedCadenceType
        )

        // Save to scoreboard
        if let result = currentResult {
            saveToScoreboard(result)
        }
        
        // Calculate rating change
        let ratingChange = calculateRatingChange(correctAnswers: correctAnswers, totalQuestions: totalQuestions)
        
        // Apply to shared player stats
        let wasPerfectScore = correctAnswers == totalQuestions
        let ratingResult = playerStats.applyRatingChange(ratingChange)
        playerStats.updateStreak()
        playerStats.recordPractice(
            questionsAnswered: totalQuestions,
            correctAnswers: correctAnswers,
            time: totalQuizTime,
            wasPerfectScore: wasPerfectScore
        )
        
        // Record to PlayerProfile for RPG stats
        PlayerProfile.shared.recordPractice(
            mode: .cadenceDrill,
            questions: totalQuestions,
            correct: correctAnswers,
            time: totalQuizTime
        )
        PlayerProfile.shared.addXP(ratingChange, from: .cadenceDrill)
        
        // Record curriculum progress if there's an active module
        Task { @MainActor in
            if let activeModuleID = CurriculumManager.shared.activeModuleID {
                let wasPerfectScore = correctAnswers == totalQuestions
                CurriculumManager.shared.recordModuleAttempt(
                    moduleID: activeModuleID,
                    questionsAnswered: totalQuestions,
                    correctAnswers: correctAnswers,
                    wasPerfectSession: wasPerfectScore
                )
                CurriculumManager.shared.setActiveModule(nil)
            }
        }
        
        // Store for UI
        lastRatingChange = ratingChange
        didRankUp = ratingResult.didRankUp
        previousLevel = ratingResult.previousLevel
        
        // Update mode-specific lifetime statistics
        updateLifetimeStats(ratingChange: ratingChange)
        
        // Phase 4: Save settings for quick practice
        saveLastQuizSettings()
        
        // Set completion LAST to trigger view transition AFTER currentResult is ready
        isQuizCompleted = true
    }
    
    /// Calculate rating change based on performance
    private func calculateRatingChange(correctAnswers: Int, totalQuestions: Int) -> Int {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        
        // Base points from accuracy
        var points: Double = 0
        
        if accuracy >= 1.0 {
            points = 35  // Perfect score bonus (cadences are harder)
        } else if accuracy >= 0.9 {
            points = 25
        } else if accuracy >= 0.8 {
            points = 18
        } else if accuracy >= 0.7 {
            points = 12
        } else if accuracy >= 0.6 {
            points = 6
        } else if accuracy >= 0.5 {
            points = 0  // Break even
        } else if accuracy >= 0.3 {
            points = -5
        } else {
            points = -10
        }
        
        // Drill mode multiplier (harder modes = more points)
        let modeMultiplier: Double
        switch selectedDrillMode {
        case .fullProgression:
            modeMultiplier = 1.0
        case .commonTones:
            modeMultiplier = 1.3  // Different skill
        case .chordIdentification:
            modeMultiplier = 1.2  // Chord symbol recognition
        case .auralIdentify:
            modeMultiplier = 1.8  // Ear training is harder
        case .guideTones:
            modeMultiplier = 1.4  // Guide tone resolution
        case .resolutionTargets:
            modeMultiplier = 1.4  // Resolution targets
        }
        
        // Cadence type complexity bonus
        let cadenceMultiplier: Double
        switch selectedCadenceType {
        case .major, .minor:
            cadenceMultiplier = 1.0
        case .tritoneSubstitution, .backdoor:
            cadenceMultiplier = 1.3
        case .birdChanges:
            cadenceMultiplier = 1.5
        }
        
        // Key difficulty multiplier
        let keyMultiplier: Double
        switch selectedKeyDifficulty {
        case .easy:
            keyMultiplier = 0.7
        case .medium:
            keyMultiplier = 1.0
        case .hard:
            keyMultiplier = 1.3
        case .expert:
            keyMultiplier = 1.5
        case .all:
            keyMultiplier = 1.1
        }
        
        // Question count bonus (more questions = more reliable score)
        let questionBonus = Double(totalQuestions) / 10.0
        
        // Speed bonus (if fast and accurate)
        let avgTimePerQuestion = totalQuizTime / Double(totalQuestions)
        let speedBonus: Double
        if accuracy >= 0.7 && avgTimePerQuestion < 8.0 {
            speedBonus = 1.2
        } else if accuracy >= 0.7 && avgTimePerQuestion < 15.0 {
            speedBonus = 1.1
        } else {
            speedBonus = 1.0
        }
        
        // Hint penalty (using hints reduces points)
        let hintPenalty: Double = max(0.5, 1.0 - (Double(totalHintsUsed) * 0.1))
        
        let finalPoints = points * modeMultiplier * cadenceMultiplier * keyMultiplier * questionBonus * speedBonus * hintPenalty
        
        // Ensure rating doesn't go below 0
        let newRating = max(0, lifetimeStats.currentRating + Int(finalPoints.rounded()))
        return newRating - lifetimeStats.currentRating
    }
    
    // MARK: - Mistake Review Drill
    
    /// Returns questions that were answered incorrectly
    func getMissedQuestions() -> [CadenceQuestion] {
        guard let result = currentResult else { return [] }
        
        return questions.filter { question in
            let isCorrectAnswer = result.isCorrect[question.id.uuidString] ?? true
            return !isCorrectAnswer
        }
    }
    
    /// Start a new quiz with only the missed questions from the last quiz
    func startMistakeReviewDrill() {
        let missedQuestions = getMissedQuestions()
        guard !missedQuestions.isEmpty else { return }
        
        // Reset state
        currentQuestionIndex = 0
        userAnswers = [:]
        totalQuizTime = 0
        isQuizActive = true
        isQuizCompleted = false
        currentResult = nil
        quizStartTime = Date()
        hintsUsedThisQuestion = 0
        totalHintsUsed = 0
        currentHintLevel = 0
        
        // Use the missed questions
        questions = missedQuestions
        totalQuestions = missedQuestions.count
        
        if !questions.isEmpty {
            currentQuestion = questions[0]
            questionStartTime = Date()
        }
    }
    
    /// Returns true if there are missed questions to review
    var hasMissedQuestions: Bool {
        return !getMissedQuestions().isEmpty
    }

    func isAnswerCorrect(userAnswer: [[Note]], question: CadenceQuestion) -> Bool {
        // Special handling for different drill modes
        switch question.drillMode {
        case .guideTones:
            return isGuideToneAnswerCorrect(userAnswer: userAnswer, question: question)
        case .resolutionTargets:
            return isResolutionTargetCorrect(userAnswer: userAnswer, question: question)
        default:
            // Standard answer checking for other modes
            break
        }
        
        // Use expectedAnswers which handles both full progression and isolated chord modes
        let correctAnswers = question.expectedAnswers

        // Helper function to normalize MIDI number to pitch class (0-11)
        // This makes comparison octave-agnostic (C4 == C5 == C3)
        func pitchClass(_ midiNumber: Int) -> Int {
            // MIDI note % 12 gives pitch class: C=0, C#=1, D=2, etc.
            return midiNumber % 12
        }

        // Check the expected number of chords based on drill mode
        guard userAnswer.count == correctAnswers.count else { return false }

        for i in 0..<correctAnswers.count {
            let userChordNotes = userAnswer[i]
            let correctChordNotes = correctAnswers[i]

            // Convert to pitch class sets for comparison
            // Using Set means order doesn't matter (inversions are accepted)
            // Using pitchClass means octave doesn't matter
            let userPitchClasses = Set(userChordNotes.map { pitchClass($0.midiNumber) })
            let correctPitchClasses = Set(correctChordNotes.map { pitchClass($0.midiNumber) })

            // Debug logging (can be removed later)
            // print("User pitch classes: \(userPitchClasses), Correct: \(correctPitchClasses)")

            // If any chord is incorrect, the whole answer is wrong
            if userPitchClasses != correctPitchClasses {
                return false
            }
        }

        return true
    }
    
    /// Check if guide tone answer is correct (must play ONLY 3rd and 7th for each chord)
    private func isGuideToneAnswerCorrect(userAnswer: [[Note]], question: CadenceQuestion) -> Bool {
        guard userAnswer.count == question.cadence.chords.count else { return false }
        
        func pitchClass(_ midiNumber: Int) -> Int {
            return midiNumber % 12
        }
        
        for i in 0..<question.cadence.chords.count {
            let userNotes = userAnswer[i]
            let correctGuideTones = question.guideTonesForChord(i)
            
            let userPitchClasses = Set(userNotes.map { pitchClass($0.midiNumber) })
            let correctPitchClasses = Set(correctGuideTones.map { pitchClass($0.midiNumber) })
            
            // Must match exactly (only 3rd and 7th, nothing else)
            if userPitchClasses != correctPitchClasses {
                return false
            }
        }
        
        return true
    }
    
    /// Check if resolution target answer is correct
    private func isResolutionTargetCorrect(userAnswer: [[Note]], question: CadenceQuestion) -> Bool {
        guard let pairs = question.resolutionPairs,
              let currentIndex = question.currentResolutionIndex,
              currentIndex < pairs.count,
              userAnswer.count > 0,
              userAnswer[0].count > 0 else { return false }
        
        let pair = pairs[currentIndex]
        guard let targetNote = pair.targetNote else { return false }
        
        func pitchClass(_ midiNumber: Int) -> Int {
            return midiNumber % 12
        }
        
        // User should have played exactly one note
        let userNote = userAnswer[0][0]
        return pitchClass(userNote.midiNumber) == pitchClass(targetNote.midiNumber)
    }
    
    // Note: isSmoothVoicingCorrect removed - mode moved to future Voice Leading module

    // MARK: - Scoreboard Management

    @Published var scoreboard: [CadenceResult] = []

    private func saveToScoreboard(_ result: CadenceResult) {
        scoreboard.append(result)
        scoreboard.sort { first, second in
            // Sort by accuracy first, then by time
            if first.accuracy != second.accuracy {
                return first.accuracy > second.accuracy
            }
            return first.totalTime < second.totalTime
        }

        // Keep only top 10
        if scoreboard.count > 10 {
            scoreboard = Array(scoreboard.prefix(10))
        }

        // Save to UserDefaults
        saveScoreboardToUserDefaults()
    }

    func saveScoreboardToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(scoreboard) {
            UserDefaults.standard.set(encoded, forKey: "JazzHarmonyCadenceScoreboard")
        }
    }

    func loadScoreboardFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "JazzHarmonyCadenceScoreboard"),
           let decoded = try? JSONDecoder().decode([CadenceResult].self, from: data) {
            scoreboard = decoded
        }
    }

    // MARK: - Timer Management

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Update any timer-related UI if needed
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Question Navigation

    func canGoToNextQuestion() -> Bool {
        return currentQuestionIndex < questions.count - 1
    }

    func canGoToPreviousQuestion() -> Bool {
        return currentQuestionIndex > 0
    }

    func goToNextQuestion() {
        if canGoToNextQuestion() {
            currentQuestionIndex += 1
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        }
    }

    func goToPreviousQuestion() {
        if canGoToPreviousQuestion() {
            currentQuestionIndex -= 1
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        }
    }

    // MARK: - Chord Identification Mode Support
    
    /// Tracks chord selections for chord identification mode
    @Published var chordIdentificationAnswers: [UUID: [ChordSelection]] = [:]
    
    /// Whether this is the last question
    var isLastQuestion: Bool {
        return currentQuestionIndex >= questions.count - 1
    }
    
    /// Advance to next question (public method for chord identification)
    func advanceToNextQuestion() {
        currentQuestionIndex += 1
        hintsUsedThisQuestion = 0
        currentHintLevel = 0
        
        if currentQuestionIndex < questions.count {
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        }
    }
    
    /// Record a chord identification answer
    func recordChordIdentificationAnswer(selections: [ChordSelection], isCorrect: Bool) {
        guard let question = currentQuestion else { return }
        
        // Store the selections
        chordIdentificationAnswers[question.id] = selections
        
        // Also store as note arrays for compatibility with existing results
        let noteArrays: [[Note]] = selections.map { selection in
            guard let root = selection.selectedRoot else { return [] }
            return [root] // Simplified - just store the root for identification mode
        }
        userAnswers[question.id] = noteArrays
        
        // Update time
        if let startTime = questionStartTime {
            totalQuizTime += Date().timeIntervalSince(startTime)
        }
    }
    
    /// End the quiz and show results
    func endQuiz() {
        finishQuiz()
    }
    
    // MARK: - Progress Tracking

    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestionIndex) / Double(totalQuestions)
    }

    var currentQuestionNumber: Int {
        return currentQuestionIndex + 1
    }

    var answeredQuestions: Int {
        return userAnswers.count
    }

    // MARK: - Statistics

    var currentScore: Int {
        guard !questions.isEmpty else { return 0 }

        var correct = 0
        for question in questions {
            if let userAnswer = userAnswers[question.id] {
                if isAnswerCorrect(userAnswer: userAnswer, question: question) {
                    correct += 1
                }
            }
        }

        return Int((Double(correct) / Double(questions.count)) * 100)
    }

    var averageTimePerQuestion: TimeInterval {
        guard answeredQuestions > 0 else { return 0 }
        return totalQuizTime / Double(answeredQuestions)
    }

    // MARK: - State Management

    // MARK: - Guide Tone Helper Methods
    
    /// Generate resolution pairs for a cadence (for resolution targets drill)
    private func generateResolutionPairs(for cadence: CadenceProgression) -> [ResolutionPair] {
        guard cadence.chords.count >= 3 else { return [] }
        
        var pairs: [ResolutionPair] = []
        
        // ii → V resolutions
        let iiChord = cadence.chords[0]
        let vChord = cadence.chords[1]
        
        // 3rd of ii resolves to 7th of V
        if let iiThird = iiChord.third, let vSeventh = vChord.seventh {
            pairs.append(ResolutionPair(
                sourceNote: iiThird,
                targetNote: vSeventh,
                sourceChordIndex: 0,
                targetChordIndex: 1,
                sourceRole: .third
            ))
        }
        
        // 7th of ii resolves to 3rd of V
        if let iiSeventh = iiChord.seventh, let vThird = vChord.third {
            pairs.append(ResolutionPair(
                sourceNote: iiSeventh,
                targetNote: vThird,
                sourceChordIndex: 0,
                targetChordIndex: 1,
                sourceRole: .seventh
            ))
        }
        
        // V → I resolutions
        let iChord = cadence.chords[2]
        
        // 3rd of V resolves to 7th of I (or stays as common tone)
        if let vThird = vChord.third, let iSeventh = iChord.seventh {
            pairs.append(ResolutionPair(
                sourceNote: vThird,
                targetNote: iSeventh,
                sourceChordIndex: 1,
                targetChordIndex: 2,
                sourceRole: .third
            ))
        }
        
        // 7th of V resolves to 3rd of I
        if let vSeventh = vChord.seventh, let iThird = iChord.third {
            pairs.append(ResolutionPair(
                sourceNote: vSeventh,
                targetNote: iThird,
                sourceChordIndex: 1,
                targetChordIndex: 2,
                sourceRole: .seventh
            ))
        }
        
        return pairs
    }
    
    /// Generate a voicing constraint for smooth voicing drill
    private func generateVoicingConstraint() -> VoicingConstraint {
        // Random top voice motion
        let motions: [VoiceMotion] = [.halfStepUp, .halfStepDown, .wholeStepUp, .wholeStepDown, .common]
        let motion = motions.randomElement() ?? .halfStepDown
        
        // Maximum total motion depends on difficulty
        // Easier = more motion allowed, harder = less motion allowed
        let maxMotion = Int.random(in: 4...8)
        
        return VoicingConstraint(topVoiceMotion: motion, maxTotalMotion: maxMotion)
    }
    
    func resetQuizState() {
        isQuizCompleted = false
        currentResult = nil
        isQuizActive = false
        currentQuestion = nil
        currentQuestionIndex = 0
        userAnswers = [:]
        totalQuizTime = 0
        questionStartTime = nil
        quizStartTime = nil
        hintsUsedThisQuestion = 0
        totalHintsUsed = 0
        currentHintLevel = 0
        
        stopTimer()
    }
    
    // MARK: - Streak Management
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastPractice = lastPracticeDate {
            let lastPracticeDay = calendar.startOfDay(for: lastPractice)
            let daysDifference = calendar.dateComponents([.day], from: lastPracticeDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                // Already practiced today, streak unchanged
                return
            } else if daysDifference == 1 {
                // Practiced yesterday, increment streak
                currentStreak += 1
            } else {
                // Missed a day, reset streak
                currentStreak = 1
            }
        } else {
            // First time practicing
            currentStreak = 1
        }
        
        lastPracticeDate = today
        saveStreakToUserDefaults()
    }
    
    func saveStreakToUserDefaults() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(lastPracticeDate, forKey: lastPracticeDateKey)
    }
    
    func loadStreakFromUserDefaults() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        lastPracticeDate = UserDefaults.standard.object(forKey: lastPracticeDateKey) as? Date
        
        // Check if streak should be reset (missed more than one day)
        if let lastPractice = lastPracticeDate {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let lastPracticeDay = calendar.startOfDay(for: lastPractice)
            let daysDifference = calendar.dateComponents([.day], from: lastPracticeDay, to: today).day ?? 0
            
            if daysDifference > 1 {
                // Missed more than one day, streak resets on next practice
                currentStreak = 0
            }
        }
    }
    
    // MARK: - Hint System
    
    /// Request a hint for the current question. Returns the hint text or nil if no more hints available.
    func requestHint(for chordIndex: Int) -> String? {
        guard let question = currentQuestion else { return nil }
        guard currentHintLevel < 3 else { return nil }
        
        currentHintLevel += 1
        hintsUsedThisQuestion += 1
        totalHintsUsed += 1
        
        let chord = question.chordsToSpell[min(chordIndex, question.chordsToSpell.count - 1)]
        
        switch currentHintLevel {
        case 1:
            // Level 1: Show chord formula
            return hintFormula(for: chord)
        case 2:
            // Level 2: Show intervals in semitones
            return hintIntervals(for: chord)
        case 3:
            // Level 3: Reveal the root note
            return hintFirstNote(for: chord)
        default:
            return nil
        }
    }
    
    private func hintFormula(for chord: Chord) -> String {
        let toneNames = chord.chordType.chordTones.map { $0.name }
        return "Formula: \(toneNames.joined(separator: " - "))"
    }
    
    private func hintIntervals(for chord: Chord) -> String {
        let intervals = chord.chordType.chordTones.map { "\($0.semitonesFromRoot)" }
        return "Semitones from root: \(intervals.joined(separator: ", "))"
    }
    
    private func hintFirstNote(for chord: Chord) -> String {
        return "Root note: \(chord.root.name)"
    }
    
    /// Returns true if hints are still available for current question
    var canRequestHint: Bool {
        return currentHintLevel < 3
    }
    
    /// Returns accuracy penalty based on hints used (0.0 to 1.0 multiplier)
    var hintPenalty: Double {
        switch hintsUsedThisQuestion {
        case 0: return 1.0      // Full credit
        case 1: return 0.75     // 75% credit
        case 2: return 0.5      // 50% credit
        default: return 0.25    // 25% credit for 3+ hints
        }
    }
    
    // MARK: - Phase 4: Statistics Management
    
    func saveLifetimeStats() {
        if let encoded = try? JSONEncoder().encode(lifetimeStats) {
            UserDefaults.standard.set(encoded, forKey: lifetimeStatsKey)
        }
    }
    
    func loadLifetimeStats() {
        if let data = UserDefaults.standard.data(forKey: lifetimeStatsKey),
           let decoded = try? JSONDecoder().decode(CadenceLifetimeStats.self, from: data) {
            lifetimeStats = decoded
        }
    }
    
    func saveLastQuizSettings() {
        let settings = LastQuizSettings(
            numberOfQuestions: totalQuestions,
            cadenceType: selectedCadenceType,
            drillMode: selectedDrillMode,
            keyDifficulty: selectedKeyDifficulty,
            useMixedCadences: useMixedCadences,
            useExtendedVChords: useExtendedVChords,
            extendedVChord: selectedExtendedVChord
        )
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: lastQuizSettingsKey)
        }
        lastQuizSettings = settings
    }
    
    func loadLastQuizSettings() {
        if let data = UserDefaults.standard.data(forKey: lastQuizSettingsKey),
           let decoded = try? JSONDecoder().decode(LastQuizSettings.self, from: data) {
            lastQuizSettings = decoded
        }
    }
    
    /// Update lifetime stats after a quiz completes
    func updateLifetimeStats(ratingChange: Int) {
        guard let result = currentResult else { return }
        lifetimeStats.recordQuizResult(result, questions: questions, ratingChange: ratingChange)
        saveLifetimeStats()
    }
    
    // MARK: - Phase 5: Weak Key Practice & Encouragement
    
    /// Start a practice session focused on weak keys
    func startWeakKeyPractice() {
        let weakKeys = lifetimeStats.getWeakestKeys(limit: 3)
        guard !weakKeys.isEmpty else {
            // Not enough data, start normal practice
            startNewQuiz(numberOfQuestions: 5, cadenceType: .major)
            return
        }
        
        // Create questions focused on weak keys
        questions = []
        let database = JazzChordDatabase.shared
        
        for _ in 0..<5 {
            // Pick from weak keys
            let weakKey = weakKeys.randomElement()!
            
            // Find the matching Note
            let allRoots = KeyDifficulty.all.availableRoots
            guard let keyNote = allRoots.first(where: { $0.name == weakKey.key }) else { continue }
            
            // Create cadence with the weak key
            let cadence = CadenceProgression(key: keyNote, cadenceType: selectedCadenceType)
            let question = CadenceQuestion(
                cadence: cadence,
                drillMode: .fullProgression,
                isolatedPosition: nil
            )
            questions.append(question)
        }
        
        // Start the quiz
        totalQuestions = questions.count
        currentQuestionIndex = 0
        userAnswers = [:]
        totalQuizTime = 0
        isQuizActive = true
        isQuizCompleted = false
        currentResult = nil
        quizStartTime = Date()
        hintsUsedThisQuestion = 0
        totalHintsUsed = 0
        currentHintLevel = 0
        
        updateStreak()
        
        if !questions.isEmpty {
            currentQuestion = questions[0]
            questionStartTime = Date()
        }
    }
    
    /// Whether weak key practice is available (has enough data)
    var canPracticeWeakKeys: Bool {
        return lifetimeStats.hasEnoughDataForAnalysis && !lifetimeStats.getWeakestKeys().isEmpty
    }
    
    /// Get encouragement message for current result
    func getEncouragementMessage() -> EncouragementMessage? {
        guard let result = currentResult else { return nil }
        return EncouragementEngine.getMessage(for: result, stats: lifetimeStats, isNewPersonalBest: false)
    }
    
    /// Get streak encouragement if applicable
    func getStreakEncouragement() -> String? {
        return EncouragementEngine.getStreakMessage(streak: currentStreak)
    }
    
    // MARK: - Spaced Repetition Integration
    
    /// Record spaced repetition results for all questions in the quiz
    private func recordSpacedRepetitionResults() {
        let srStore = SpacedRepetitionStore.shared
        
        for question in questions {
            let userAnswer = userAnswers[question.id] ?? [[], [], []]
            let wasCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
            
            // Calculate time spent on this question (estimate based on total quiz time)
            let avgTimePerQuestion = totalQuizTime / Double(totalQuestions)
            
            // Create SR item ID based on drill mode
            let itemID: SRItemID
            
            switch selectedDrillMode {
            case .fullProgression:
                // Record the full cadence in this key
                itemID = SRItemID(
                    mode: .cadenceDrill,
                    topic: selectedCadenceType.rawValue,
                    key: question.cadence.key.name,
                    variant: "full"
                )
                
            case .chordIdentification:
                // Record chord identification practice
                itemID = SRItemID(
                    mode: .cadenceDrill,
                    topic: "chord-id",
                    key: question.cadence.key.name,
                    variant: selectedCadenceType.rawValue
                )
                
            case .auralIdentify:
                // Record ear training practice
                itemID = SRItemID(
                    mode: .cadenceDrill,
                    topic: "aural-identify",
                    key: question.cadence.key.name,
                    variant: selectedCadenceType.rawValue
                )
                
            case .guideTones:
                // Record guide tone practice
                itemID = SRItemID(
                    mode: .cadenceDrill,
                    topic: "guide-tones",
                    key: question.cadence.key.name,
                    variant: selectedCadenceType.rawValue
                )
                
            case .commonTones:
                // Record common tone practice
                itemID = SRItemID(
                    mode: .cadenceDrill,
                    topic: "common-tones",
                    key: question.cadence.key.name,
                    variant: selectedCadenceType.rawValue
                )
                
            case .resolutionTargets:
                // Record resolution target practice
                itemID = SRItemID(
                    mode: .cadenceDrill,
                    topic: "resolution-targets",
                    key: question.cadence.key.name,
                    variant: selectedCadenceType.rawValue
                )
            }
            
            // Record result
            srStore.recordResult(
                itemID: itemID,
                wasCorrect: wasCorrect,
                responseTime: avgTimePerQuestion
            )
        }
    }

    // MARK: - Initialization

    init() {
        loadScoreboardFromUserDefaults()
        loadStreakFromUserDefaults()
        loadLifetimeStats()
        loadLastQuizSettings()
        // Reset quiz state on app launch
        resetQuizState()
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Seeded Random Number Generator

/// A random number generator that produces deterministic results from a seed
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        // xorshift64 algorithm
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

// MARK: - Phase 4: Statistics & Quick Practice Models

/// Tracks lifetime statistics for the cadence drill
struct CadenceLifetimeStats: Codable {
    var totalQuestionsAnswered: Int = 0
    var totalCorrectAnswers: Int = 0
    var totalQuizzesTaken: Int = 0
    var totalPracticeTime: TimeInterval = 0
    
    // Rating system
    var currentRating: Int = 1000  // Start at "Jam Session Ready"
    var peakRating: Int = 1000
    
    // Per-cadence type stats
    var statsByCadenceType: [String: CadenceTypeStats] = [:]
    
    // Per-key stats
    var statsByKey: [String: KeyStats] = [:]
    
    // Personal bests
    var personalBests: [String: PersonalBest] = [:]  // Key is "cadenceType_key" e.g., "major_C"
    
    var overallAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
    }
    
    var currentRank: Rank {
        return Rank.forRating(currentRating)
    }
    
    var pointsToNextRank: Int? {
        guard let nextRank = Rank.nextRank(after: currentRank) else { return nil }
        return nextRank.minRating - currentRating
    }
    
    var averageTimePerQuestion: TimeInterval {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return totalPracticeTime / Double(totalQuestionsAnswered)
    }
    
    mutating func recordQuizResult(_ result: CadenceResult, questions: [CadenceQuestion], ratingChange: Int) {
        totalQuizzesTaken += 1
        totalQuestionsAnswered += result.totalQuestions
        totalCorrectAnswers += result.correctAnswers
        totalPracticeTime += result.totalTime
        
        // Apply rating change
        currentRating += ratingChange
        peakRating = max(peakRating, currentRating)
        
        // Update per-cadence stats
        let cadenceKey = result.cadenceType.rawValue
        var cadenceStats = statsByCadenceType[cadenceKey] ?? CadenceTypeStats()
        cadenceStats.questionsAnswered += result.totalQuestions
        cadenceStats.correctAnswers += result.correctAnswers
        statsByCadenceType[cadenceKey] = cadenceStats
        
        // Update per-key stats from questions
        for question in questions {
            let keyName = question.cadence.key.name
            var keyStats = statsByKey[keyName] ?? KeyStats()
            keyStats.questionsAnswered += 1
            if result.isCorrect[question.id.uuidString] == true {
                keyStats.correctAnswers += 1
            }
            statsByKey[keyName] = keyStats
        }
    }
    
    mutating func checkAndUpdatePersonalBest(cadenceType: CadenceType, key: String, time: TimeInterval, accuracy: Double) -> Bool {
        let pbKey = "\(cadenceType.rawValue)_\(key)"
        
        if let existing = personalBests[pbKey] {
            // Better if higher accuracy, or same accuracy but faster time
            if accuracy > existing.accuracy || (accuracy == existing.accuracy && time < existing.time) {
                personalBests[pbKey] = PersonalBest(time: time, accuracy: accuracy, date: Date())
                return true
            }
            return false
        } else {
            // First time for this combination
            personalBests[pbKey] = PersonalBest(time: time, accuracy: accuracy, date: Date())
            return true
        }
    }
}

struct CadenceTypeStats: Codable {
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
}

struct KeyStats: Codable {
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
}

struct PersonalBest: Codable {
    let time: TimeInterval
    let accuracy: Double
    let date: Date
}

/// Settings for quiz mode - saves last used settings
struct LastQuizSettings: Codable {
    var numberOfQuestions: Int = 5
    var cadenceType: CadenceType = .major
    var drillMode: CadenceDrillMode = .fullProgression
    var keyDifficulty: KeyDifficulty = .all
    var useMixedCadences: Bool = false
    var useExtendedVChords: Bool = false
    var extendedVChord: ExtendedVChordOption = .basic
}

// MARK: - Phase 5: Encouragement & Analysis

/// Generates contextual encouragement messages based on performance
struct EncouragementEngine {
    
    /// Get encouragement message for quiz results
    static func getMessage(for result: CadenceResult, stats: CadenceLifetimeStats, isNewPersonalBest: Bool) -> EncouragementMessage {
        let accuracy = result.accuracy
        
        // Check for milestones first
        if let milestone = checkMilestone(stats: stats, result: result) {
            return milestone
        }
        
        // Personal best celebration
        if isNewPersonalBest {
            return EncouragementMessage(
                emoji: "🏆",
                title: "New Personal Best!",
                message: "You beat your previous record!",
                type: .celebration
            )
        }
        
        // Perfect score
        if accuracy == 1.0 {
            let perfectMessages = [
                "Flawless! You nailed every chord!",
                "Perfect score! Charlie Parker would be proud!",
                "100%! You're a chord spelling machine!",
                "Incredible! Not a single mistake!"
            ]
            return EncouragementMessage(
                emoji: "🌟",
                title: "Perfect!",
                message: perfectMessages.randomElement() ?? perfectMessages[0],
                type: .celebration
            )
        }
        
        // High accuracy (90%+)
        if accuracy >= 0.9 {
            return EncouragementMessage(
                emoji: "🔥",
                title: "Excellent!",
                message: "You're really getting these cadences down!",
                type: .positive
            )
        }
        
        // Good accuracy (70-89%)
        if accuracy >= 0.7 {
            return EncouragementMessage(
                emoji: "💪",
                title: "Good Work!",
                message: "Solid performance! Keep practicing to master those tricky ones.",
                type: .positive
            )
        }
        
        // Moderate accuracy (50-69%)
        if accuracy >= 0.5 {
            return EncouragementMessage(
                emoji: "📈",
                title: "Making Progress!",
                message: "You're getting there! Try using hints if you get stuck.",
                type: .encouraging
            )
        }
        
        // Low accuracy (<50%)
        return EncouragementMessage(
            emoji: "🎯",
            title: "Keep Going!",
            message: "Every mistake is a learning opportunity. Try the Mistake Review to focus on trouble spots!",
            type: .encouraging
        )
    }
    
    /// Check for milestone achievements
    static func checkMilestone(stats: CadenceLifetimeStats, result: CadenceResult) -> EncouragementMessage? {
        let totalQuestions = stats.totalQuestionsAnswered
        
        // First perfect score ever
        if result.accuracy == 1.0 && stats.totalQuizzesTaken == 1 {
            return EncouragementMessage(
                emoji: "🎉",
                title: "First Perfect Score!",
                message: "Amazing start! You got every chord right on your first try!",
                type: .milestone
            )
        }
        
        // Question milestones
        if totalQuestions >= 1000 && totalQuestions - result.totalQuestions < 1000 {
            return EncouragementMessage(
                emoji: "🏅",
                title: "1,000 Questions!",
                message: "You've answered over 1,000 questions! Dedication pays off!",
                type: .milestone
            )
        }
        
        if totalQuestions >= 500 && totalQuestions - result.totalQuestions < 500 {
            return EncouragementMessage(
                emoji: "⭐",
                title: "500 Questions!",
                message: "Half a thousand chords spelled! You're becoming a pro!",
                type: .milestone
            )
        }
        
        if totalQuestions >= 100 && totalQuestions - result.totalQuestions < 100 {
            return EncouragementMessage(
                emoji: "🎊",
                title: "100 Questions!",
                message: "You've hit triple digits! The chords are becoming second nature!",
                type: .milestone
            )
        }
        
        // Quiz milestones
        if stats.totalQuizzesTaken == 10 {
            return EncouragementMessage(
                emoji: "🔟",
                title: "10 Quizzes Complete!",
                message: "Double digits! You're building a solid practice habit!",
                type: .milestone
            )
        }
        
        return nil
    }
    
    /// Get streak-based encouragement
    static func getStreakMessage(streak: Int) -> String? {
        switch streak {
        case 3:
            return "3 days in a row! You're building momentum! 🔥"
        case 7:
            return "One week streak! Consistency is key to mastery! 🎯"
        case 14:
            return "Two weeks strong! Your chord spelling is getting solid! 💪"
        case 30:
            return "30 day streak! You're officially dedicated! 🏆"
        case 100:
            return "100 DAY STREAK! You're a legend! 👑"
        default:
            return nil
        }
    }
}

struct EncouragementMessage {
    let emoji: String
    let title: String
    let message: String
    let type: MessageType
    
    enum MessageType {
        case celebration
        case positive
        case encouraging
        case milestone
    }
}

/// Extension to add weak key detection to stats
extension CadenceLifetimeStats {
    
    /// Get the weakest keys based on accuracy (minimum 5 questions attempted)
    func getWeakestKeys(limit: Int = 3) -> [(key: String, accuracy: Double)] {
        let minQuestions = 5
        
        return statsByKey
            .filter { $0.value.questionsAnswered >= minQuestions }
            .map { (key: $0.key, accuracy: $0.value.accuracy) }
            .sorted { $0.accuracy < $1.accuracy }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get the strongest keys based on accuracy (minimum 5 questions attempted)
    func getStrongestKeys(limit: Int = 3) -> [(key: String, accuracy: Double)] {
        let minQuestions = 5
        
        return statsByKey
            .filter { $0.value.questionsAnswered >= minQuestions }
            .map { (key: $0.key, accuracy: $0.value.accuracy) }
            .sorted { $0.accuracy > $1.accuracy }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get keys that need more practice (low question count)
    func getUnderPracticedKeys() -> [String] {
        let allKeys = ["C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
        let minQuestions = 5
        
        return allKeys.filter { key in
            let stats = statsByKey[key]
            return (stats?.questionsAnswered ?? 0) < minQuestions
        }
    }
    
    /// Get the weakest cadence types
    func getWeakestCadenceTypes(limit: Int = 2) -> [(type: String, accuracy: Double)] {
        let minQuestions = 3
        
        return statsByCadenceType
            .filter { $0.value.questionsAnswered >= minQuestions }
            .map { (type: $0.key, accuracy: $0.value.accuracy) }
            .sorted { $0.accuracy < $1.accuracy }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Check if user has enough data for meaningful analysis
    var hasEnoughDataForAnalysis: Bool {
        return totalQuestionsAnswered >= 20
    }
}
