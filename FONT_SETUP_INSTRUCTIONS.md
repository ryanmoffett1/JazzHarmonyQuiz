# Font Setup Instructions for Xcode

## Overview
The Jazz Harmony Quiz app now includes the Caveat font, a handwritten Google Font licensed under the SIL Open Font License. This font needs to be properly registered in Xcode for the app to use it.

## Font Location
The Caveat font file is located at:
```
Jazz Harmony Quiz/JazzHarmonyQuiz/Fonts/Caveat-VariableFont.ttf
```

## Setup Steps in Xcode

### 1. Add Font to Project
1. Open the project in Xcode
2. In the Project Navigator, locate the `Fonts` folder
3. If the font file is not already visible, drag `Caveat-VariableFont.ttf` into the project
4. When prompted, ensure:
   - ✅ "Copy items if needed" is checked
   - ✅ "Add to targets" has the main app target selected
   - ✅ "Create groups" is selected

### 2. Register Font in Info.plist
1. Open the `Info.plist` file (or the Info tab in project settings)
2. Add a new key called **"Fonts provided by application"** (or `UIAppFonts` if using raw keys)
3. Add a new item to the array with the value: `Caveat-VariableFont.ttf`

Alternatively, you can edit the Info.plist as source code and add:
```xml
<key>UIAppFonts</key>
<array>
    <string>Caveat-VariableFont.ttf</string>
</array>
```

### 3. Verify Font Installation
To verify the font is properly installed, you can add this temporary code to your app:
```swift
// Print all available fonts (for debugging)
for family in UIFont.familyNames.sorted() {
    let names = UIFont.fontNames(forFamilyName: family)
    print("Family: \(family) Font names: \(names)")
}
```

Look for "Caveat" in the console output.

### 4. Font Usage in Code
The font is already configured in the `SettingsManager.swift` file:
```swift
case .caveat:
    return .custom("Caveat", size: size + 4)
```

## Font License
**Caveat** is licensed under the **SIL Open Font License, Version 1.1**
- Free to use commercially
- Can be bundled, embedded, and redistributed
- Source: Google Fonts / GitHub

## Troubleshooting

### Font Not Displaying
If the font doesn't appear:
1. Verify the font file is in the Copy Bundle Resources build phase:
   - Select the project in Navigator
   - Select the target
   - Go to Build Phases
   - Expand "Copy Bundle Resources"
   - Ensure `Caveat-VariableFont.ttf` is listed
   - If not listed, click the `+` button and add `Caveat-VariableFont.ttf` from the file browser

2. Clean build folder (Product → Clean Build Folder) and rebuild

3. Check that the font name in code matches exactly (case-sensitive)

### Finding Font Family Name
If "Caveat" doesn't work, the actual font family name might be different. Use this code to find it:
```swift
if let fontURL = Bundle.main.url(forResource: "Caveat-VariableFont", withExtension: "ttf"),
   let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
   let font = CGFont(fontDataProvider) {
    print("Font PostScript name: \(font.postScriptName ?? "unknown")")
}
```

## References
- [Caveat on Google Fonts](https://fonts.google.com/specimen/Caveat)
- [Caveat GitHub Repository](https://github.com/googlefonts/caveat)
- [SIL Open Font License](https://scripts.sil.org/OFL)
