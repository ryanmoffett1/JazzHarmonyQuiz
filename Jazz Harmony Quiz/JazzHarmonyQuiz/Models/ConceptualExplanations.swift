import Foundation

/// Provides educational explanations for chords, scales, progressions, and intervals
/// to help students understand WHY things work, not just memorize them
struct ConceptualExplanations {
    static let shared = ConceptualExplanations()
    
    // MARK: - Chord Explanations
    
    /// Get explanation for a specific chord type
    func chordExplanation(for chordType: ChordType) -> ChordConcept {
        chordConcepts[chordType.symbol] ?? defaultChordConcept
    }
    
    /// Get explanation for why a chord appears in a specific context
    func contextualChordExplanation(chord: Chord, context: HarmonicContext) -> String {
        switch context {
        case .majorKey(let function):
            return majorKeyChordExplanation(chord: chord, function: function)
        case .minorKey(let function):
            return minorKeyChordExplanation(chord: chord, function: function)
        case .standalone:
            return chordExplanation(for: chord.chordType).theory
        }
    }
    
    // MARK: - Scale Explanations
    
    func scaleExplanation(for scale: ScaleType) -> ScaleConcept {
        scaleConcepts[scale.name] ?? defaultScaleConcept
    }
    
    // MARK: - Interval Explanations
    
    func intervalExplanation(for interval: IntervalType) -> IntervalConcept {
        intervalConcepts[interval.name] ?? defaultIntervalConcept
    }
    
    // MARK: - Progression Explanations
    
    func progressionExplanation(for progression: String) -> ProgressionConcept {
        progressionConcepts[progression] ?? defaultProgressionConcept
    }
    
    // MARK: - Private Implementations
    
    private func majorKeyChordExplanation(chord: Chord, function: ChordFunction) -> String {
        switch function {
        case .tonic:
            return "The I chord (\(chord.displayName)) is the tonic – the home base of the key. It provides the most stable, resolved sound. In jazz, we almost always use Imaj7 instead of a triad."
        case .subdominant:
            return "The ii chord (\(chord.displayName)) is the subdominant. It creates gentle tension that wants to move to the V chord. This is why ii-V-I is the most fundamental progression in jazz."
        case .dominant:
            if chord.chordType.symbol.contains("alt") || chord.chordType.symbol.contains("b9") {
                return "The V chord (\(chord.displayName)) is the dominant with alterations. The b9, #9, #5, or b13 create more tension, making the resolution to I even stronger. This is very common in modern jazz."
            } else {
                return "The V chord (\(chord.displayName)) is the dominant. The tritone (b7 and 3) creates strong tension that wants to resolve down to the I chord. This tension-release is the heart of functional harmony."
            }
        case .submediant:
            return "The vi chord (\(chord.displayName)) is the submediant. It shares two notes with the I chord (root and 3rd), making it sound like a softer version of tonic. Common in turnarounds: I-vi-ii-V."
        case .mediant:
            return "The iii chord (\(chord.displayName)) is the mediant. It's less common in jazz but can substitute for the I chord or act as a passing chord."
        }
    }
    
    private func minorKeyChordExplanation(chord: Chord, function: ChordFunction) -> String {
        switch function {
        case .tonic:
            return "The i chord (\(chord.displayName)) is the tonic in minor. It's the home base, providing stability. We typically use im7 or im(maj7) in jazz."
        case .subdominant:
            return "The iim7♭5 chord (\(chord.displayName)) is the subdominant in minor. The half-diminished quality comes from the natural minor scale and leads beautifully to V7."
        case .dominant:
            return "The V7 chord (\(chord.displayName)) functions the same in minor as major – it creates tension that wants to resolve to i. We often add b9 in minor for extra color."
        case .submediant:
            return "The VI chord (\(chord.displayName)) is the relative major. It shares the same notes as the parent major key and provides a bright contrast in minor."
        case .mediant:
            return "The III chord (\(chord.displayName)) is the relative major's tonic. It's common in modal jazz and provides a temporary escape from minor."
        }
    }
    
    // MARK: - Content Databases
    
    private let chordConcepts: [String: ChordConcept] = [
        "maj7": ChordConcept(
            name: "Major 7th",
            theory: "A major triad (1-3-5) plus the major 7th. This is the jazz version of a major chord – brighter and more sophisticated than a simple triad.",
            sound: "Bright, stable, warm. Think of the opening chord of 'Stairway to Heaven' or the Imaj7 in 'Girl from Ipanema'.",
            usage: "Use for I and IV chords in major keys. It's the most consonant chord in jazz harmony.",
            voicingTip: "Try playing root, 3rd, 5th, 7th. The half-step between the 7th and root (up top) creates a beautiful shimmer."
        ),
        "m7": ChordConcept(
            name: "Minor 7th",
            theory: "A minor triad (1-♭3-5) plus the minor 7th. The workhorse of jazz harmony – appears in every ii-V-I.",
            sound: "Mellow, relaxed, contemplative. Not as dark as diminished, not as bright as major.",
            usage: "Most common on ii chords in major (Dm7 in C major) and i chords in minor. Also vi chords in major keys.",
            voicingTip: "The minor 7th is less dissonant than the major 7th, so it blends smoothly. Try dropping the 5th for a more modern sound."
        ),
        "7": ChordConcept(
            name: "Dominant 7th",
            theory: "A major triad (1-3-5) plus the minor 7th. The ♭7 against the major 3rd creates a tritone – the most unstable interval.",
            sound: "Tense, bluesy, wants to resolve. The tritone (3-♭7) is dying to move somewhere.",
            usage: "Almost always on V chords. The tritone resolves to I: 3rd moves up to tonic, ♭7 moves down to 3rd of I.",
            voicingTip: "Focus on the tritone (3rd and ♭7) – those are the 'guide tones' that define the chord's function."
        ),
        "m7b5": ChordConcept(
            name: "Minor 7th ♭5 (Half-Diminished)",
            theory: "A diminished triad (1-♭3-♭5) plus the minor 7th. Called 'half-diminished' because it's not fully diminished (which would have a ♭♭7).",
            sound: "Tense, unstable, searching. More ambiguous than a regular minor chord.",
            usage: "Most common on ii chords in MINOR keys (Dm7♭5 in C minor). Creates a strong pull to V7.",
            voicingTip: "The ♭5 is the key color tone. Make sure it's audible – it's what distinguishes this from a regular m7."
        ),
        "dim7": ChordConcept(
            name: "Diminished 7th",
            theory: "Four notes, each a minor 3rd apart: 1-♭3-♭5-♭♭7 (which is the same as 6). This creates a symmetrical chord.",
            sound: "Very tense, spooky, unstable. Because it's symmetrical, it can resolve in multiple directions.",
            usage: "Passing chord between two chords a half-step apart. Also as a vii°7 leading to I. Common in older jazz standards.",
            voicingTip: "Any note can be the root! G°7 = B♭°7 = D♭°7 = E°7. Use this to create smooth voice leading."
        ),
        "maj6": ChordConcept(
            name: "Major 6th",
            theory: "A major triad (1-3-5) plus the major 6th. Very similar sound to maj7, but the 6th is less dissonant.",
            sound: "Bright, happy, complete. Slightly less sophisticated than maj7 but more stable.",
            usage: "Common on I chords, especially in swing-era standards. Can substitute for maj7 in most cases.",
            voicingTip: "The 6th blends better than the 7th because it doesn't create a half-step with the root."
        ),
        "7b9": ChordConcept(
            name: "Dominant 7th ♭9",
            theory: "A dominant 7th chord (1-3-5-♭7) plus the ♭9. The ♭9 clashes beautifully with the root and 3rd.",
            sound: "Very tense, dark, urgent. The ♭9 adds a 'crunchy' dissonance that screams for resolution.",
            usage: "On V7 chords when you want extra tension. Especially common resolving to minor (V7♭9 to im7).",
            voicingTip: "Stack 3-♭7-♭9 without the root for a modern sound. Pianists and guitarists love this voicing."
        ),
        "7#9": ChordConcept(
            name: "Dominant 7th #9",
            theory: "A dominant 7th chord plus the #9 (which is the same pitch as a ♭3). This creates the 'Hendrix chord' sound.",
            sound: "Bluesy, funky, ambiguous. The #9 sounds like both major and minor at the same time.",
            usage: "Blues, R&B, and modern jazz. Creates a bluesy dominant sound that still functions as V7.",
            voicingTip: "Works great with a ♭7 and no 5th. The #9 against the 3rd is the key color."
        ),
        "7alt": ChordConcept(
            name: "Dominant 7th Altered",
            theory: "A dominant 7th with altered 5ths and 9ths: typically ♭9, #9, ♭5, and/or #5. Very dissonant.",
            sound: "Maximum tension. Like a V7 chord on steroids. Demands resolution.",
            usage: "Modern jazz. When you want the strongest possible V7 sound. Often used in bebop and beyond.",
            voicingTip: "Use the altered scale (7th mode of melodic minor up a half-step). Focus on 3-♭7-♭9-#9."
        ),
        "m(maj7)": ChordConcept(
            name: "Minor-Major 7th",
            theory: "A minor triad (1-♭3-5) plus the MAJOR 7th. Creates a dark-bright contrast.",
            sound: "Mysterious, haunting, bittersweet. The major 7th against the minor 3rd creates interesting tension.",
            usage: "On i chords in minor when using harmonic or melodic minor. Also works for cinematic, mysterious moods.",
            voicingTip: "The major 7th wants to resolve up to the root (octave above). Handle it carefully."
        ),
        "maj7#5": ChordConcept(
            name: "Major 7th #5 (Augmented Major 7th)",
            theory: "A major triad with raised 5th (1-3-#5) plus the major 7th. The augmented triad creates an unstable foundation.",
            sound: "Bright, dreamy, floating. The #5 makes it sound like it's going somewhere.",
            usage: "Imaj7#5 in major keys, especially as a passing chord or in modern/contemporary jazz contexts.",
            voicingTip: "The #5 is the color tone – make sure it's prominent in the voicing."
        ),
        "sus4": ChordConcept(
            name: "Suspended 4th",
            theory: "Replaces the 3rd with a 4th (1-4-5) in a triad. In jazz, usually sus4 with a ♭7 (1-4-5-♭7).",
            sound: "Neutral, floating, unresolved. No major or minor quality because there's no 3rd.",
            usage: "Often on V chords instead of V7. Creates a more open, modal sound. The 4 wants to resolve down to the 3.",
            voicingTip: "Beautiful for creating space and ambiguity. Works great in modal jazz."
        )
    ]
    
    private let defaultChordConcept = ChordConcept(
        name: "Jazz Chord",
        theory: "This chord extends the basic triad with additional notes to create richer harmony.",
        sound: "Each chord has its own character and color in jazz harmony.",
        usage: "Understanding chord function and context is key to using this chord effectively.",
        voicingTip: "Experiment with different voicings to bring out the characteristic tones."
    )
    
    private let scaleConcepts: [String: ScaleConcept] = [
        "Major": ScaleConcept(
            name: "Major Scale",
            theory: "The foundation of Western music: W-W-H-W-W-W-H pattern. All other scales are compared to this one.",
            sound: "Bright, happy, complete. The 'do-re-mi' scale everyone learns first.",
            usage: "Use over Imaj7 chords. Also the parent scale for all seven modes (Ionian, Dorian, Phrygian, etc.).",
            parentScale: nil,
            modesRelation: "Parent scale. Contains all seven modes starting from different scale degrees."
        ),
        "Dorian": ScaleConcept(
            name: "Dorian Mode",
            theory: "2nd mode of major scale. Minor scale with a raised 6th: 1-2-♭3-4-5-6-♭7.",
            sound: "Minor, but brighter than natural minor. The major 6th gives it a jazzy, hopeful quality.",
            usage: "The go-to scale for minor 7th chords in jazz. Use it over iim7 in major keys (Dm7 in C major).",
            parentScale: "Major scale, starting from the 2nd degree",
            modesRelation: "C Dorian = B♭ Major scale starting from C"
        ),
        "Mixolydian": ScaleConcept(
            name: "Mixolydian Mode",
            theory: "5th mode of major scale. Major scale with a ♭7: 1-2-3-4-5-6-♭7.",
            sound: "Major, but with a bluesy edge. The ♭7 against major quality creates dominant character.",
            usage: "Perfect for dominant 7th chords. Use it over V7 chords in major keys.",
            parentScale: "Major scale, starting from the 5th degree",
            modesRelation: "G Mixolydian = C Major scale starting from G"
        ),
        "Lydian": ScaleConcept(
            name: "Lydian Mode",
            theory: "4th mode of major scale. Major scale with a #4: 1-2-3-#4-5-6-7.",
            sound: "Very bright, dreamy, floating. Brighter than major due to the #4.",
            usage: "Use over Imaj7 or IVmaj7 chords. Creates a more modern, sophisticated major sound.",
            parentScale: "Major scale, starting from the 4th degree",
            modesRelation: "F Lydian = C Major scale starting from F"
        ),
        "Altered": ScaleConcept(
            name: "Altered Scale",
            theory: "7th mode of melodic minor. Has all altered dominant tensions: ♭9, #9, #11(♭5), ♭13(#5).",
            sound: "Maximum tension. Dark, unstable, demanding resolution.",
            usage: "Use over V7alt chords. The ultimate dominant scale for creating tension before resolving to I.",
            parentScale: "Melodic minor scale up a half-step",
            modesRelation: "G Altered = A♭ Melodic Minor starting from G"
        ),
        "Diminished": ScaleConcept(
            name: "Diminished Scale (Half-Whole)",
            theory: "Symmetrical scale alternating half and whole steps: H-W-H-W-H-W-H-W.",
            sound: "Tense, colorful, symmetrical. Works for both dim7 and dom7♭9 chords.",
            usage: "Use over V7♭9 chords or dim7 chords. Provides rich altered tensions.",
            parentScale: nil,
            modesRelation: "Symmetrical – repeats every minor 3rd. G dim = B♭ dim = D♭ dim = E dim."
        ),
        "Whole Tone": ScaleConcept(
            name: "Whole Tone Scale",
            theory: "Six notes, all a whole step apart: W-W-W-W-W-W. Creates maximum ambiguity.",
            sound: "Dreamy, floating, unresolved. No perfect 5th = no tonal center.",
            usage: "Use over V7+5 or augmented chords. Creates a 'searching,' impressionistic sound.",
            parentScale: nil,
            modesRelation: "Only two whole tone scales exist (starting from any note gives you one of two collections)."
        )
    ]
    
    private let defaultScaleConcept = ScaleConcept(
        name: "Jazz Scale",
        theory: "Jazz scales extend beyond simple major and minor to create richer melodic possibilities.",
        sound: "Each scale has its own color and emotional quality.",
        usage: "The right scale choice depends on the chord and harmonic context.",
        parentScale: nil,
        modesRelation: "Understanding modal relationships helps you see connections between scales."
    )
    
    private let intervalConcepts: [String: IntervalConcept] = [
        "Perfect Unison": IntervalConcept(
            name: "Perfect Unison",
            theory: "Two notes at the exact same pitch. Zero semitones apart.",
            sound: "Complete unity – two voices singing the same note.",
            usage: "Foundation of harmony. Starting point for understanding all other intervals."
        ),
        "Minor 2nd": IntervalConcept(
            name: "Minor 2nd (Half Step)",
            theory: "The smallest interval in Western music: 1 semitone.",
            sound: "Very dissonant, tense, crunchy. Creates the strongest need for resolution.",
            usage: "Essential in voice leading (7th resolving down to 3rd). Also creates the 'crunchy' sound in ♭9 chords."
        ),
        "Major 2nd": IntervalConcept(
            name: "Major 2nd (Whole Step)",
            theory: "2 semitones apart. The basis of the major scale pattern.",
            sound: "Mildly dissonant but smooth. More stable than a minor 2nd.",
            usage: "Common in melodies and voice leading. The 9th extension in chords."
        ),
        "Minor 3rd": IntervalConcept(
            name: "Minor 3rd",
            theory: "3 semitones apart. Defines minor quality in chords.",
            sound: "Sad, dark, melancholic. The sound of minor chords.",
            usage: "The interval from root to 3rd in minor chords. Also creates diminished triads (stacked m3rds)."
        ),
        "Major 3rd": IntervalConcept(
            name: "Major 3rd",
            theory: "4 semitones apart. Defines major quality in chords.",
            sound: "Bright, happy, stable. The sound of major chords.",
            usage: "The interval from root to 3rd in major chords. Essential for establishing major tonality."
        ),
        "Perfect 4th": IntervalConcept(
            name: "Perfect 4th",
            theory: "5 semitones apart. Called 'perfect' because it's the same in major and minor.",
            sound: "Open, neutral, stable. Very consonant.",
            usage: "Common in melodies. Creates sus4 chords when used instead of the 3rd."
        ),
        "Tritone": IntervalConcept(
            name: "Tritone (Augmented 4th / Diminished 5th)",
            theory: "6 semitones apart – exactly half an octave. The 'devil's interval.'",
            sound: "Maximum tension. Unstable, ambiguous, demanding resolution.",
            usage: "The interval between 3rd and ♭7th in dominant 7th chords. Creates the dominant function."
        ),
        "Perfect 5th": IntervalConcept(
            name: "Perfect 5th",
            theory: "7 semitones apart. The most consonant interval after the octave.",
            sound: "Open, hollow, strong. The sound of power chords.",
            usage: "Foundation of triads and basic harmony. Present in almost all chords."
        ),
        "Minor 6th": IntervalConcept(
            name: "Minor 6th",
            theory: "8 semitones apart. Same as an augmented 5th enharmonically.",
            sound: "Tense but sweet. More dissonant than major 6th.",
            usage: "Common in melodies. The ♭13 in altered dominant chords."
        ),
        "Major 6th": IntervalConcept(
            name: "Major 6th",
            theory: "9 semitones apart. Creates a warm, consonant sound.",
            sound: "Sweet, consonant, complete. Not as bright as a major 7th.",
            usage: "The 6th in maj6 chords. Creates a more stable sound than maj7."
        ),
        "Minor 7th": IntervalConcept(
            name: "Minor 7th",
            theory: "10 semitones apart. Creates dominant 7th and minor 7th chords.",
            sound: "Mildly dissonant, bluesy, jazzy. Less tense than major 7th.",
            usage: "The 7th in dominant and minor 7th chords. Essential for creating jazz harmony."
        ),
        "Major 7th": IntervalConcept(
            name: "Major 7th",
            theory: "11 semitones apart – just one semitone below the octave.",
            sound: "Bright, shimmery, tense. Creates a beautiful dissonance.",
            usage: "The 7th in major 7th chords. The half-step to the root creates sophistication."
        ),
        "Perfect Octave": IntervalConcept(
            name: "Perfect Octave",
            theory: "12 semitones apart – the same note but higher or lower.",
            sound: "Complete unity. Sounds like the same note in a different register.",
            usage: "Reinforces the root. Creates fullness in voicings."
        )
    ]
    
    private let defaultIntervalConcept = IntervalConcept(
        name: "Musical Interval",
        theory: "The distance between two pitches measured in semitones.",
        sound: "Each interval has its own characteristic sound and emotional quality.",
        usage: "Intervals are the building blocks of melody and harmony."
    )
    
    private let progressionConcepts: [String: ProgressionConcept] = [
        "ii-V-I": ProgressionConcept(
            name: "ii-V-I Progression",
            theory: "The fundamental progression in jazz. Minor ii sets up dominant V, which resolves to major I. Each chord has a specific function: subdominant → dominant → tonic.",
            sound: "Smooth, inevitable, satisfying. The V-I resolution is the strongest in music; adding the ii makes it even smoother.",
            usage: "Appears in almost every jazz standard. Practice this progression in all 12 keys – it's the foundation of jazz improvisation.",
            voiceLeading: "Guide tones (3rds and 7ths) move by half or whole step: Dm7 (F-C) → G7 (F-B) → Cmaj7 (E-B). This smooth motion is why it sounds so good.",
            commonVariations: ["ii-V-I with tritone sub (ii-♭II7-I)", "ii-V-I in minor (iim7♭5-V7-im7)", "Extended ii-V-I with sus4 (iim7-V7sus4-V7-Imaj7)"]
        ),
        "I-vi-ii-V": ProgressionConcept(
            name: "I-vi-ii-V Turnaround",
            theory: "Starts from I and cycles through chords to get back to I. Called a 'turnaround' because it turns around to the beginning.",
            sound: "Circular, cyclical, forward-moving. Creates momentum that wants to return to the I chord.",
            usage: "Commonly used at the end of a form to set up the next chorus. Heard in thousands of standards from the '30s and '40s.",
            voiceLeading: "Each chord moves smoothly to the next with minimal voice movement. The vi and ii share two notes with I.",
            commonVariations: ["I-VI7-ii-V (secondary dominant on vi)", "I-vi-ii-V with tritone subs", "I-bIII-bVI-bII (chromatic turnaround)"]
        ),
        "Rhythm Changes": ProgressionConcept(
            name: "Rhythm Changes (A Section)",
            theory: "Based on 'I Got Rhythm' by Gershwin. The A section is essentially I-vi-ii-V repeated in 4 different keys, cycling by fourths.",
            sound: "Bright, energetic, swinging. Fast harmonic rhythm creates excitement.",
            usage: "One of the most common progressions for jazz compositions. Hundreds of bebop tunes use these changes.",
            voiceLeading: "Rapidly moving through keys requires strong voice leading skills. Focus on guide tones to navigate smoothly.",
            commonVariations: ["Adding secondary dominants", "Using tritone substitutions", "Expanding to 16-bar form with bridge"]
        ),
        "Blues": ProgressionConcept(
            name: "12-Bar Blues",
            theory: "I7 for 4 bars, IV7 for 2 bars, back to I7 for 2 bars, then V7-IV7-I7-V7 for the last 4 bars. All dominant 7th chords.",
            sound: "Earthy, fundamental, universal. The foundation of American music.",
            usage: "Essential for jazz musicians. Learn to play and improvise over blues in all keys.",
            voiceLeading: "Since all chords are dominant 7ths, voice leading is simpler than in ii-V-I progressions.",
            commonVariations: ["Jazz blues (adding ii-V-I in bars 9-10)", "Bird blues (Charlie Parker changes)", "Minor blues"]
        ),
        "Coltrane Changes": ProgressionConcept(
            name: "Coltrane Changes (Giant Steps)",
            theory: "Moves through three tonal centers a major 3rd apart (B, G, E♭). Each has its own ii-V-I, creating rapid modulation.",
            sound: "Angular, modern, challenging. Extremely fast harmonic rhythm.",
            usage: "Advanced modern jazz. Requires deep understanding of ii-V-I in multiple keys simultaneously.",
            voiceLeading: "The bass moves in a symmetrical pattern. Requires careful practice to navigate smoothly.",
            commonVariations: ["Countdown (applying same concept to different tunes)", "Using substitute changes over standard progressions"]
        )
    ]
    
    private let defaultProgressionConcept = ProgressionConcept(
        name: "Jazz Progression",
        theory: "Jazz progressions create harmonic motion through functional chord relationships.",
        sound: "Each progression has its own characteristic sound and emotional trajectory.",
        usage: "Understanding common progressions helps you learn tunes faster and improvise more effectively.",
        voiceLeading: "Smooth voice leading creates natural-sounding progressions.",
        commonVariations: []
    )
}

// MARK: - Concept Models

struct ChordConcept {
    let name: String
    let theory: String      // What it is
    let sound: String       // How it sounds / emotional quality
    let usage: String       // When/where to use it
    let voicingTip: String  // How to voice it
}

struct ScaleConcept {
    let name: String
    let theory: String
    let sound: String
    let usage: String
    let parentScale: String?
    let modesRelation: String
}

struct IntervalConcept {
    let name: String
    let theory: String
    let sound: String
    let usage: String
}

struct ProgressionConcept {
    let name: String
    let theory: String
    let sound: String
    let usage: String
    let voiceLeading: String
    let commonVariations: [String]
}

// MARK: - Harmonic Context

enum HarmonicContext {
    case majorKey(function: ChordFunction)
    case minorKey(function: ChordFunction)
    case standalone
}

enum ChordFunction {
    case tonic          // I or i
    case subdominant    // ii or IV
    case dominant       // V
    case submediant     // vi
    case mediant        // iii
}
