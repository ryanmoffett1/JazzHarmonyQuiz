# SoundFont Setup Instructions for Piano Audio

## Overview

The Jazz Harmony Quiz app uses `AVAudioUnitSampler` to play piano sounds for chords and scales. For consistent, high-quality audio across all devices (simulator and physical iPhone/iPad), you should bundle a SoundFont (`.sf2`) file with the app.

## The Problem

Without a bundled SoundFont:
- **iOS Simulator**: Uses macOS system DLS instrument file - sounds like a nice acoustic piano
- **Physical Device**: Uses default AVAudioUnitSampler synthesis - sounds like a basic electric piano/sine wave

This inconsistency occurs because the macOS DLS file (`/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls`) only exists on the simulator (which runs on macOS), not on actual iOS devices.

## Solution: Bundle a Piano SoundFont

### Step 1: Download a Free Piano SoundFont

Recommended free piano SoundFonts:

1. **GeneralUser GS** (recommended)
   - URL: https://schristiancollins.com/generaluser.php
   - Size: ~30MB
   - License: Free for any use
   - Note: Contains many instruments; app will use Program 0 (Acoustic Grand Piano)

2. **Salamander Grand Piano**
   - URL: https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html
   - Size: ~400MB (high quality) or smaller versions available
   - License: Creative Commons

3. **FluidR3_GM**
   - URL: https://member.keymusician.com/Member/FluidR3_GM/index.html
   - Size: ~140MB
   - License: Free

4. **Smaller alternatives** (search for "free piano sf2"):
   - Many compact piano-only SoundFonts are 1-5MB
   - Good for keeping app size small

### Step 2: Add SoundFont to Xcode Project

1. **Rename the file** to `Piano.sf2` (this exact name is required)

2. **Add to project:**
   - Drag `Piano.sf2` into the Xcode project navigator
   - Place it in the main app folder (`JazzHarmonyQuiz/`)
   - When prompted:
     - ✅ "Copy items if needed" is checked
     - ✅ "Add to targets" has `JazzHarmonyQuiz` selected
     - ✅ "Create groups" is selected

3. **Verify Bundle Resources:**
   - Select the project in Navigator
   - Select the `JazzHarmonyQuiz` target
   - Go to **Build Phases** tab
   - Expand **"Copy Bundle Resources"**
   - Ensure `Piano.sf2` is listed
   - If not, click `+` and add it

### Step 3: Verify Setup

The `AudioManager.swift` file is already configured to look for `Piano.sf2`. Once added, you'll see this in the console when the app launches:

```
Loaded bundled Piano.sf2
```

If you see this instead, the SoundFont wasn't found:
```
Using default sampler (consider adding Piano.sf2 for better sound)
```

## File Location

After setup, your project structure should include:

```
JazzHarmonyQuiz/
├── JazzHarmonyQuizApp.swift
├── ContentView.swift
├── Piano.sf2              ← SoundFont file goes here
├── Assets.xcassets/
├── Fonts/
├── Helpers/
│   └── AudioManager.swift  ← Loads the SoundFont
├── Models/
└── Views/
```

## How AudioManager Loads Sounds

The `AudioManager.swift` tries to load sounds in this order:

1. **Bundled SoundFont** (`Piano.sf2`) - Best quality, consistent everywhere
2. **System DLS** (simulator only) - Nice piano, but simulator-only
3. **Default Sampler** - Basic synthesis, works but sounds different

```swift
// From AudioManager.swift
if let soundFontURL = Bundle.main.url(forResource: "Piano", withExtension: "sf2") {
    try sampler.loadSoundBankInstrument(
        at: soundFontURL,
        program: 0,  // Acoustic Grand Piano
        bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
        bankLSB: UInt8(kAUSampler_DefaultBankLSB)
    )
}
```

## App Size Considerations

SoundFont files can be large. Consider these options:

| Option | Size | Quality |
|--------|------|---------|
| No SoundFont | 0 MB | Basic (inconsistent) |
| Small piano SF2 | 1-5 MB | Good |
| Medium GM SF2 | 30-50 MB | Great |
| Full piano SF2 | 100+ MB | Excellent |

For a quiz app, a 1-5 MB piano SoundFont is usually sufficient and won't significantly increase app download size.

## Troubleshooting

### SoundFont Not Loading
1. Verify filename is exactly `Piano.sf2` (case-sensitive)
2. Check it's in "Copy Bundle Resources" build phase
3. Clean build folder (Product → Clean Build Folder)
4. Delete app from device/simulator and reinstall

### No Sound at All
1. Check device is not in silent mode
2. Verify `AudioManager.shared.isEnabled` is `true`
3. Check Settings → Sound is enabled in the app
4. Look for errors in Xcode console

### Wrong Instrument Sound
The code loads `program: 0` which should be Acoustic Grand Piano in General MIDI. If your SoundFont uses a different program number for piano, update this line in `AudioManager.swift`:

```swift
try sampler.loadSoundBankInstrument(
    at: soundFontURL,
    program: 0,  // Change this number if needed
    ...
)
```

## References

- [AVAudioUnitSampler Documentation](https://developer.apple.com/documentation/avfaudio/avaudiounitsampler)
- [SoundFont Technical Specification](http://www.synthfont.com/sfspec24.pdf)
- [Free SoundFont Resources](https://musical-artifacts.com/artifacts?formats=sf2)
