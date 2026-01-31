#!/usr/bin/env python3
import re

# Read the project file
with open('JazzHarmonyQuiz.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# UUIDs for new files
VM_FILE_UUID = "8BF493D838B94315B19952FC"
VM_BUILD_UUID = "50D081DD15174045962DE9EF"
TEST_FILE_UUID = "7F9A7D96DD8847438527768A"
TEST_BUILD_UUID = "BCB4F13E032C46C7BE6BFC04"

# 1. Add PBXBuildFile entries (in Begin PBXBuildFile section)
build_file_pattern = r'(/\* Begin PBXBuildFile section \*/\n)'
build_file_addition = f'''\\1\t\t{VM_BUILD_UUID} /* QuickPracticeViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {VM_FILE_UUID} /* QuickPracticeViewModel.swift */; }};
\t\t{TEST_BUILD_UUID} /* QuickPracticeViewModelTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {TEST_FILE_UUID} /* QuickPracticeViewModelTests.swift */; }};
'''
content = re.sub(build_file_pattern, build_file_addition, content, count=1)

# 2. Add PBXFileReference entries (in Begin PBXFileReference section)  
file_ref_pattern = r'(/\* Begin PBXFileReference section \*/\n)'
file_ref_addition = f'''\\1\t\t{VM_FILE_UUID} /* QuickPracticeViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = QuickPracticeViewModel.swift; sourceTree = "<group>"; }};
\t\t{TEST_FILE_UUID} /* QuickPracticeViewModelTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = QuickPracticeViewModelTests.swift; sourceTree = "<group>"; }};
'''
content = re.sub(file_ref_pattern, file_ref_addition, content, count=1)

# 3. Add to Home group (find QuickPracticeSession.swift in a children array)
home_group_pattern = r'(94QKPRS22F30000000000004 /\* QuickPracticeSession\.swift \*/,\n)'
home_group_addition = f'\\1\t\t\t\t{VM_FILE_UUID} /* QuickPracticeViewModel.swift */,\n'
content = re.sub(home_group_pattern, home_group_addition, content, count=1)

# 4. Add to Features/Home test group (create if needed or add to existing)
# Look for a Home group in Tests
test_home_pattern = r'(/\* Home \*/ = \{[^}]+children = \(\n)'
if re.search(test_home_pattern, content):
    test_home_addition = f'\\1\t\t\t\t{TEST_FILE_UUID} /* QuickPracticeViewModelTests.swift */,\n'
    content = re.sub(test_home_pattern, test_home_addition, content, count=1)

# 5. Add to main target Sources build phase
sources_pattern = r'(94QKPRS12F30000000000003 /\* QuickPracticeSession\.swift in Sources \*/,\n)'
sources_addition = f'\\1\t\t\t\t{VM_BUILD_UUID} /* QuickPracticeViewModel.swift in Sources */,\n'
content = re.sub(sources_pattern, sources_addition, content, count=1)

# 6. Add to test target Sources build phase (find JazzHarmonyQuizTests target sources)
test_sources_pattern = r'(/\* QuizGameTests\.swift in Sources \*/,\n)'
if re.search(test_sources_pattern, content):
    test_sources_addition = f'\\1\t\t\t\t{TEST_BUILD_UUID} /* QuickPracticeViewModelTests.swift in Sources */,\n'
    content = re.sub(test_sources_pattern, test_sources_addition, content, count=1)

# Write back
with open('JazzHarmonyQuiz.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("✅ Added QuickPracticeViewModel.swift to project")
print("✅ Added QuickPracticeViewModelTests.swift to project")
