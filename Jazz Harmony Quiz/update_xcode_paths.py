#!/usr/bin/env python3
"""
Update Xcode project.pbxproj file paths after moving files to new locations.
"""

import sys

# Define file path mappings (old -> new)
PATH_MAPPINGS = {
    # Databases
    'Models/JazzChordDatabase.swift': 'Core/Databases/ChordDatabase.swift',
    'Models/JazzScaleDatabase.swift': 'Core/Databases/ScaleDatabase.swift',
    'Models/IntervalDatabase.swift': 'Core/Databases/IntervalDatabase.swift',
    'Models/ProgressionDatabase.swift': 'Core/Databases/CadenceDatabase.swift',
    'Models/CurriculumDatabase.swift': 'Core/Databases/CurriculumDatabase.swift',
    
    # Services
    'Helpers/AudioManager.swift': 'Core/Services/AudioManager.swift',
    'Models/SpacedRepetition.swift': 'Core/Services/SpacedRepetitionStore.swift',
    'Models/CurriculumManager.swift': 'Core/Services/CurriculumManager.swift',
    'Models/SettingsManager.swift': 'Core/Services/SettingsManager.swift',
}

# Also update the filename itself for renamed files
FILENAME_MAPPINGS = {
    'JazzChordDatabase.swift': 'ChordDatabase.swift',
    'JazzScaleDatabase.swift': 'ScaleDatabase.swift',
    'ProgressionDatabase.swift': 'CadenceDatabase.swift',
    'SpacedRepetition.swift': 'SpacedRepetitionStore.swift',
}

def update_project_file(filepath):
    """Update the Xcode project file with new paths."""
    print(f"Reading {filepath}...")
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    changes_made = 0
    
    # Update full paths (e.g., Models/JazzChordDatabase.swift)
    for old_path, new_path in PATH_MAPPINGS.items():
        if old_path in content:
            count = content.count(old_path)
            content = content.replace(old_path, new_path)
            changes_made += count
            print(f"  ✓ Updated {count} full path references: {old_path} -> {new_path}")
    
    # Also update paths in quoted contexts (path = "Models/...")
    for old_path, new_path in PATH_MAPPINGS.items():
        old_quoted = f'"{old_path}"'
        new_quoted = f'"{new_path}"'
        if old_quoted in content:
            count = content.count(old_quoted)
            content = content.replace(old_quoted, new_quoted)
            changes_made += count
            print(f"  ✓ Updated {count} quoted path references: {old_path} -> {new_path}")
    
    # Update filenames in name/path attributes
    for old_name, new_name in FILENAME_MAPPINGS.items():
        # Update in path = "filename.swift" contexts
        old_pattern = f'path = {old_name};'
        new_pattern = f'path = {new_name};'
        if old_pattern in content:
            count = content.count(old_pattern)
            content = content.replace(old_pattern, new_pattern)
            changes_made += count
            print(f"  ✓ Updated {count} path attributes: {old_name} -> {new_name}")
        
        # Update in name = "filename.swift" contexts  
        old_pattern = f'name = {old_name};'
        new_pattern = f'name = {new_name};'
        if old_pattern in content:
            count = content.count(old_pattern)
            content = content.replace(old_pattern, new_pattern)
            changes_made += count
            print(f"  ✓ Updated {count} name attributes: {old_name} -> {new_name}")
    
    if changes_made > 0:
        print(f"\nWriting updated project file ({changes_made} total changes)...")
        with open(filepath, 'w') as f:
            f.write(content)
        print("✅ Project file updated successfully!")
        return True
    else:
        print("⚠️  No changes needed - paths already up to date or not found")
        return False

if __name__ == '__main__':
    project_file = 'JazzHarmonyQuiz.xcodeproj/project.pbxproj'
    
    try:
        success = update_project_file(project_file)
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
