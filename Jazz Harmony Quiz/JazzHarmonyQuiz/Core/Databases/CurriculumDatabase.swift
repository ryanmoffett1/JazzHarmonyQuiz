import Foundation

/// Database of all curriculum modules
struct CurriculumDatabase {
    
    // MARK: - All Modules
    
    static let modules: [CurriculumModule] = [
        // PATHWAY 1: HARMONY FOUNDATIONS
        // Level 1: Triads
        harmonyFoundations_1_1_majorMinorTriads,
        harmonyFoundations_1_2_dimAugTriads,
        harmonyFoundations_1_3_allTriadsAllKeys,
        
        // Level 2: 7th Chords
        harmonyFoundations_2_1_basicSevenths,
        harmonyFoundations_2_2_halfDimDim,
        harmonyFoundations_2_3_allSeventhsAllKeys,
        
        // Level 3: Extensions
        harmonyFoundations_3_1_ninthChords,
        harmonyFoundations_3_2_alteredDominants,
        harmonyFoundations_3_3_eleventhThirteenth,
        
        // PATHWAY 2: FUNCTIONAL HARMONY
        // Level 1: Basic Cadences
        functionalHarmony_1_1_majorTwoFiveOne,
        functionalHarmony_1_2_minorTwoFiveOne,
        functionalHarmony_1_3_tritoneSubstitution,
        
        // Level 2: Voice Leading
        functionalHarmony_2_1_guideTones,
        functionalHarmony_2_2_commonTones,
        functionalHarmony_2_3_smoothVoicing,
        
        // Level 3: Progressions
        functionalHarmony_3_1_turnarounds,
        functionalHarmony_3_2_rhythmChanges,
        functionalHarmony_3_3_backdoorCadence,
        
        // PATHWAY 3: EAR TRAINING
        // Level 1: Intervals
        earTraining_1_1_basicIntervals,
        earTraining_1_2_compoundIntervals,
        earTraining_1_3_allIntervalsAural,
        
        // Level 2: Chords
        earTraining_2_1_triadQuality,
        earTraining_2_2_seventhQuality,
        earTraining_2_3_extensionsAural,
        
        // Level 3: Progressions
        earTraining_3_1_cadenceRecognition,
        earTraining_3_2_progressionPatterns,
        
        // PATHWAY 4: ADVANCED TOPICS
        // Level 1: Scales
        advancedTopics_1_1_modes,
        advancedTopics_1_2_melodicMinor,
        advancedTopics_1_3_symmetrical,
        
        // Level 2: Advanced Harmony
        advancedTopics_2_1_secondaryDominants,
        advancedTopics_2_2_modalInterchange,
        advancedTopics_2_3_coltraneChanges
    ]
    
    // MARK: - Pathway 1: Harmony Foundations
    
    static let harmonyFoundations_1_1_majorMinorTriads = CurriculumModule(
        title: "Major & Minor Triads",
        description: "Learn to spell major and minor triads in easy keys (C, F, G, Dm, Am, Em)",
        emoji: "🎵",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 1,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["major", "minor"],
            questionType: "allTones",
            totalQuestions: 15,
            useAudio: true
        ),
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.85,
            minimumAttempts: 30
        )
    )
    
    static let harmonyFoundations_1_2_dimAugTriads = CurriculumModule(
        title: "Diminished & Augmented",
        description: "Master diminished and augmented triads",
        emoji: "🔺",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 2,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["dim", "aug"],
            questionType: "allTones",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [harmonyFoundations_1_1_majorMinorTriads.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.80,
            minimumAttempts: 25
        )
    )
    
    static let harmonyFoundations_1_3_allTriadsAllKeys = CurriculumModule(
        title: "All Triads, All Keys",
        description: "Spell all triad types in all 12 keys",
        emoji: "🌟",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 3,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["major", "minor", "dim", "aug"],
            questionType: "allTones",
            totalQuestions: 20,
            useAudio: true
        ),
        prerequisiteModuleIDs: [harmonyFoundations_1_2_dimAugTriads.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.90,
            minimumAttempts: 40,
            perfectSessionsRequired: 2
        )
    )
    
    static let harmonyFoundations_2_1_basicSevenths = CurriculumModule(
        title: "Basic 7th Chords",
        description: "Master maj7, m7, and dom7 in easy keys",
        emoji: "7️⃣",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 4,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["maj7", "m7", "7"],
            questionType: "allTones",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [harmonyFoundations_1_3_allTriadsAllKeys.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.85,
            minimumAttempts: 35
        )
    )
    
    static let harmonyFoundations_2_2_halfDimDim = CurriculumModule(
        title: "Half-Diminished & Diminished 7",
        description: "Learn m7♭5 and dim7 chords",
        emoji: "ø",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 5,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["m7b5", "dim7"],
            questionType: "allTones",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [harmonyFoundations_2_1_basicSevenths.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.80,
            minimumAttempts: 30
        )
    )
    
    static let harmonyFoundations_2_3_allSeventhsAllKeys = CurriculumModule(
        title: "All 7th Chords, All Keys",
        description: "Spell all 7th chord types in all 12 keys",
        emoji: "🎯",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 6,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["maj7", "m7", "7", "m7b5", "dim7"],
            questionType: "allTones",
            totalQuestions: 20,
            useAudio: true
        ),
        prerequisiteModuleIDs: [harmonyFoundations_2_2_halfDimDim.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.90,
            minimumAttempts: 50,
            perfectSessionsRequired: 3
        )
    )
    
    static let harmonyFoundations_3_1_ninthChords = CurriculumModule(
        title: "9th Chords",
        description: "Master maj9, m9, and dom9 chords",
        emoji: "9️⃣",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 7,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["maj9", "m9", "9"],
            questionType: "allTones",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [harmonyFoundations_2_3_allSeventhsAllKeys.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.80,
            minimumAttempts: 35
        )
    )
    
    static let harmonyFoundations_3_2_alteredDominants = CurriculumModule(
        title: "Altered Dominants",
        description: "Learn 7♭9, 7#9, 7♭5, 7#5 chords",
        emoji: "🎪",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 8,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["7b9", "7#9", "7b5", "7#5"],
            questionType: "allTones",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [harmonyFoundations_3_1_ninthChords.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.75,
            minimumAttempts: 40
        )
    )
    
    static let harmonyFoundations_3_3_eleventhThirteenth = CurriculumModule(
        title: "11th & 13th Chords",
        description: "Master advanced extended chords",
        emoji: "🚀",
        pathway: CurriculumPathway.harmonyFoundations,
        level: 9,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["maj13", "m11", "13", "11"],
            questionType: "allTones",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [harmonyFoundations_3_2_alteredDominants.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.75,
            minimumAttempts: 40
        )
    )
    
    // MARK: - Pathway 2: Functional Harmony
    
    static let functionalHarmony_1_1_majorTwoFiveOne = CurriculumModule(
        title: "Major ii-V-I",
        description: "Master the fundamental jazz progression in major keys",
        emoji: "🎼",
        pathway: CurriculumPathway.functionalHarmony,
        level: 1,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major"],
            drillMode: "fullProgression",
            keyDifficulty: "easy",
            totalQuestions: 10,
            useAudio: true
        ),
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.85,
            minimumAttempts: 30
        )
    )
    
    static let functionalHarmony_1_2_minorTwoFiveOne = CurriculumModule(
        title: "Minor ii-V-i",
        description: "Learn ii-V-i progressions in minor keys with V7♭9",
        emoji: "🌙",
        pathway: CurriculumPathway.functionalHarmony,
        level: 2,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["minor"],
            drillMode: "fullProgression",
            keyDifficulty: "easy",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [functionalHarmony_1_1_majorTwoFiveOne.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.80,
            minimumAttempts: 30
        )
    )
    
    static let functionalHarmony_1_3_tritoneSubstitution = CurriculumModule(
        title: "Tritone Substitution",
        description: "Master ♭II7 as a substitute for V7",
        emoji: "🔄",
        pathway: CurriculumPathway.functionalHarmony,
        level: 3,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["tritoneSub"],
            drillMode: "fullProgression",
            keyDifficulty: "medium",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [functionalHarmony_1_2_minorTwoFiveOne.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.80,
            minimumAttempts: 25
        )
    )
    
    static let functionalHarmony_2_1_guideTones = CurriculumModule(
        title: "Guide Tones (3rds & 7ths)",
        description: "Isolate and master the essential voice-leading notes",
        emoji: "🎯",
        pathway: CurriculumPathway.functionalHarmony,
        level: 4,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major", "minor"],
            drillMode: "guideTones",
            keyDifficulty: "easy",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [functionalHarmony_1_3_tritoneSubstitution.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.85,
            minimumAttempts: 35
        )
    )
    
    static let functionalHarmony_2_2_commonTones = CurriculumModule(
        title: "Common Tone Recognition",
        description: "Find notes shared between adjacent chords",
        emoji: "🔗",
        pathway: CurriculumPathway.functionalHarmony,
        level: 5,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major", "minor"],
            drillMode: "commonTones",
            keyDifficulty: "medium",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [functionalHarmony_2_1_guideTones.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.80,
            minimumAttempts: 30
        )
    )
    
    static let functionalHarmony_2_3_smoothVoicing = CurriculumModule(
        title: "Voice Leading Mastery",
        description: "Advanced guide tone and common tone practice across progressions",
        emoji: "🎹",
        pathway: CurriculumPathway.functionalHarmony,
        level: 6,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major"],
            drillMode: "guideTones",  // Using guideTones as smoothVoicing was removed
            keyDifficulty: "medium",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [functionalHarmony_2_2_commonTones.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.75,
            minimumAttempts: 25
        )
    )
    
    static let functionalHarmony_3_1_turnarounds = CurriculumModule(
        title: "Turnarounds (I-vi-ii-V)",
        description: "Master the classic turnaround progression",
        emoji: "🔁",
        pathway: CurriculumPathway.functionalHarmony,
        level: 7,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major"],
            drillMode: "fullProgression",
            keyDifficulty: "medium",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [functionalHarmony_2_3_smoothVoicing.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.80,
            minimumAttempts: 30
        )
    )
    
    static let functionalHarmony_3_2_rhythmChanges = CurriculumModule(
        title: "Rhythm Changes",
        description: "Navigate the 'I Got Rhythm' progression",
        emoji: "🎺",
        pathway: CurriculumPathway.functionalHarmony,
        level: 8,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major"],
            drillMode: "fullProgression",
            keyDifficulty: "hard",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [functionalHarmony_3_1_turnarounds.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.75,
            minimumAttempts: 35
        )
    )
    
    static let functionalHarmony_3_3_backdoorCadence = CurriculumModule(
        title: "Backdoor Cadence",
        description: "Master the ♭VII-I resolution",
        emoji: "🚪",
        pathway: CurriculumPathway.functionalHarmony,
        level: 9,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["backdoor"],
            drillMode: "fullProgression",
            keyDifficulty: "medium",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [functionalHarmony_3_2_rhythmChanges.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.75,
            minimumAttempts: 25
        )
    )
    
    // MARK: - Pathway 3: Ear Training
    
    static let earTraining_1_1_basicIntervals = CurriculumModule(
        title: "Basic Intervals by Ear",
        description: "Identify major/minor 2nds, 3rds, and perfect 4ths/5ths aurally",
        emoji: "👂",
        pathway: CurriculumPathway.earTraining,
        level: 1,
        mode: CurriculumPracticeMode.intervals,
        recommendedConfig: ModuleConfig(
            intervalTypes: ["minor 2nd", "major 2nd", "minor 3rd", "major 3rd", "perfect 4th", "perfect 5th"],
            intervalMode: "aural",
            totalQuestions: 15,
            useAudio: true
        ),
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.75,
            minimumAttempts: 40
        )
    )
    
    static let earTraining_1_2_compoundIntervals = CurriculumModule(
        title: "Compound Intervals",
        description: "Identify 6ths, 7ths, and octaves by ear",
        emoji: "🎵",
        pathway: CurriculumPathway.earTraining,
        level: 2,
        mode: CurriculumPracticeMode.intervals,
        recommendedConfig: ModuleConfig(
            intervalTypes: ["minor 6th", "major 6th", "minor 7th", "major 7th", "octave"],
            intervalMode: "aural",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [earTraining_1_1_basicIntervals.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.70,
            minimumAttempts: 40
        )
    )
    
    static let earTraining_1_3_allIntervalsAural = CurriculumModule(
        title: "All Intervals by Ear",
        description: "Identify all intervals including tritone and augmented",
        emoji: "🎧",
        pathway: CurriculumPathway.earTraining,
        level: 3,
        mode: CurriculumPracticeMode.intervals,
        recommendedConfig: ModuleConfig(
            intervalMode: "aural",
            totalQuestions: 20,
            useAudio: true
        ),
        prerequisiteModuleIDs: [earTraining_1_2_compoundIntervals.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.75,
            minimumAttempts: 50
        )
    )
    
    static let earTraining_2_1_triadQuality = CurriculumModule(
        title: "Triad Quality Recognition",
        description: "Identify major, minor, diminished, and augmented triads by ear",
        emoji: "🔊",
        pathway: CurriculumPathway.earTraining,
        level: 4,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["major", "minor", "dim", "aug"],
            questionType: "auralQuality",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [earTraining_1_3_allIntervalsAural.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.70,
            minimumAttempts: 35
        )
    )
    
    static let earTraining_2_2_seventhQuality = CurriculumModule(
        title: "7th Chord Quality",
        description: "Identify maj7, m7, dom7, m7♭5, and dim7 by ear",
        emoji: "🎼",
        pathway: CurriculumPathway.earTraining,
        level: 5,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["maj7", "m7", "7", "m7b5", "dim7"],
            questionType: "auralQuality",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [earTraining_2_1_triadQuality.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.65,
            minimumAttempts: 40
        )
    )
    
    static let earTraining_2_3_extensionsAural = CurriculumModule(
        title: "Extensions by Ear",
        description: "Identify 9ths, altered dominants, and other extensions aurally",
        emoji: "🌟",
        pathway: CurriculumPathway.earTraining,
        level: 6,
        mode: CurriculumPracticeMode.chords,
        recommendedConfig: ModuleConfig(
            chordTypes: ["maj9", "m9", "9", "7b9", "7#9"],
            questionType: "auralQuality",
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [earTraining_2_2_seventhQuality.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.60,
            minimumAttempts: 40
        )
    )
    
    static let earTraining_3_1_cadenceRecognition = CurriculumModule(
        title: "Cadence Recognition",
        description: "Identify ii-V-I, tritone sub, and other cadence types by ear",
        emoji: "🎹",
        pathway: CurriculumPathway.earTraining,
        level: 7,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major", "minor", "tritoneSub", "backdoor"],
            drillMode: "auralIdentify",
            keyDifficulty: "easy",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [earTraining_2_3_extensionsAural.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.70,
            minimumAttempts: 30
        )
    )
    
    static let earTraining_3_2_progressionPatterns = CurriculumModule(
        title: "Progression Pattern Recognition",
        description: "Identify turnarounds, rhythm changes, and other patterns by ear",
        emoji: "🎺",
        pathway: CurriculumPathway.earTraining,
        level: 8,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major", "minor", "tritoneSub"],
            drillMode: "auralIdentify",
            keyDifficulty: "medium",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [earTraining_3_1_cadenceRecognition.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.65,
            minimumAttempts: 35
        )
    )
    
    // MARK: - Pathway 4: Advanced Topics
    
    static let advancedTopics_1_1_modes = CurriculumModule(
        title: "Church Modes",
        description: "Master Ionian, Dorian, Phrygian, Lydian, Mixolydian, Aeolian, Locrian",
        emoji: "🏛️",
        pathway: CurriculumPathway.advancedTopics,
        level: 1,
        mode: CurriculumPracticeMode.scales,
        recommendedConfig: ModuleConfig(
            scaleTypes: ["Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"],
            totalQuestions: 15,
            useAudio: true
        ),
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.75,
            minimumAttempts: 40
        )
    )
    
    static let advancedTopics_1_2_melodicMinor = CurriculumModule(
        title: "Melodic Minor Modes",
        description: "Learn melodic minor and its modes (Dorian ♭2, Lydian Augmented, etc.)",
        emoji: "🌊",
        pathway: CurriculumPathway.advancedTopics,
        level: 2,
        mode: CurriculumPracticeMode.scales,
        recommendedConfig: ModuleConfig(
            scaleTypes: ["Melodic Minor", "Dorian b2", "Lydian Augmented", "Lydian Dominant", "Mixolydian b13", "Half-Diminished", "Altered"],
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [advancedTopics_1_1_modes.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.70,
            minimumAttempts: 45
        )
    )
    
    static let advancedTopics_1_3_symmetrical = CurriculumModule(
        title: "Symmetrical Scales",
        description: "Master whole tone, diminished, and augmented scales",
        emoji: "⚖️",
        pathway: CurriculumPathway.advancedTopics,
        level: 3,
        mode: CurriculumPracticeMode.scales,
        recommendedConfig: ModuleConfig(
            scaleTypes: ["Whole Tone", "Diminished (Half-Whole)", "Diminished (Whole-Half)", "Augmented"],
            totalQuestions: 15,
            useAudio: true
        ),
        prerequisiteModuleIDs: [advancedTopics_1_2_melodicMinor.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.70,
            minimumAttempts: 35
        )
    )
    
    static let advancedTopics_2_1_secondaryDominants = CurriculumModule(
        title: "Secondary Dominants",
        description: "Master V7/ii, V7/V, V7/vi and other tonicizations",
        emoji: "🎯",
        pathway: CurriculumPathway.advancedTopics,
        level: 4,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major"],
            drillMode: "fullProgression",
            keyDifficulty: "medium",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [advancedTopics_1_3_symmetrical.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.70,
            minimumAttempts: 30
        )
    )
    
    static let advancedTopics_2_2_modalInterchange = CurriculumModule(
        title: "Modal Interchange",
        description: "Borrow chords from parallel minor/major (♭VI, ♭VII, etc.)",
        emoji: "🔀",
        pathway: CurriculumPathway.advancedTopics,
        level: 5,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major", "minor"],
            drillMode: "fullProgression",
            keyDifficulty: "hard",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [advancedTopics_2_1_secondaryDominants.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.65,
            minimumAttempts: 30
        )
    )
    
    static let advancedTopics_2_3_coltraneChanges = CurriculumModule(
        title: "Coltrane Changes",
        description: "Navigate 'Giant Steps' style progressions",
        emoji: "🚀",
        pathway: CurriculumPathway.advancedTopics,
        level: 6,
        mode: CurriculumPracticeMode.cadences,
        recommendedConfig: ModuleConfig(
            cadenceTypes: ["major"],
            drillMode: "fullProgression",
            keyDifficulty: "expert",
            totalQuestions: 10,
            useAudio: true
        ),
        prerequisiteModuleIDs: [advancedTopics_2_2_modalInterchange.id],
        completionCriteria: CompletionCriteria(
            accuracyThreshold: 0.60,
            minimumAttempts: 40
        )
    )
}
