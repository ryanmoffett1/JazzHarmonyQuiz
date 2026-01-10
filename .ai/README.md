# AI Agent Documentation

This directory contains comprehensive documentation and guidelines for AI agents (Claude Code, GitHub Copilot, etc.) working on the Jazz Harmony Quiz project.

## 📁 Directory Structure

```
.ai/
├── README.md                    # This file - overview of AI documentation
├── AGENT_INSTRUCTIONS.md        # Main instructions for AI agents (START HERE)
├── PROJECT_CONTEXT.md           # Detailed architecture and components
├── CODING_STANDARDS.md          # Swift/SwiftUI conventions
├── TODO_TEMPLATE.md             # Task tracking framework
└── todos/                       # Task tracking directory
    ├── active/                  # Currently in-progress tasks
    ├── completed/               # Finished tasks (for reference)
    └── blocked/                 # Tasks waiting on external factors
```

## 🚀 Quick Start for AI Agents

If you're an AI agent working on this project, read these files in order:

1. **AGENT_INSTRUCTIONS.md** (REQUIRED)
   - Project overview
   - Core principles and guidelines
   - Common tasks and workflows
   - File modification guidelines

2. **PROJECT_CONTEXT.md** (RECOMMENDED)
   - Detailed architecture documentation
   - Component descriptions
   - Data flow patterns
   - Extension points

3. **CODING_STANDARDS.md** (REFERENCE)
   - Swift language conventions
   - SwiftUI best practices
   - Project-specific standards
   - Anti-patterns to avoid

4. **TODO_TEMPLATE.md** (AS NEEDED)
   - Task tracking framework
   - When to create TODOs
   - Example TODO workflows
   - Best practices

## 📋 For Human Developers

While these files are optimized for AI agent collaboration, human developers will also find them useful:

- **Architecture Overview:** See PROJECT_CONTEXT.md for comprehensive system design
- **Style Guide:** See CODING_STANDARDS.md for Swift/SwiftUI conventions
- **Task Tracking:** Use TODO_TEMPLATE.md for complex feature development
- **Onboarding:** AGENT_INSTRUCTIONS.md provides excellent project introduction

## 🎯 Purpose

This documentation structure enables:

1. **Consistent AI Collaboration**
   - AI agents understand project structure and conventions
   - Reduces errors and improves code quality
   - Maintains architectural integrity

2. **Effective Task Tracking**
   - Structured approach to complex features
   - Progress visibility
   - Blocker documentation

3. **Knowledge Preservation**
   - Architectural decisions documented
   - Patterns and conventions explicit
   - Lessons learned captured

## 🔄 Maintenance

### When to Update

**AGENT_INSTRUCTIONS.md:**
- Major architectural changes
- New common patterns identified
- Feature request evaluation criteria changes

**PROJECT_CONTEXT.md:**
- New components added
- Data flow changes
- Extension points modified

**CODING_STANDARDS.md:**
- New conventions adopted
- Anti-patterns discovered
- Style guide updates

**TODO_TEMPLATE.md:**
- Workflow improvements identified
- Template refinements needed

### How to Update

1. Read the existing file thoroughly
2. Make targeted changes (don't rewrite entire sections unnecessarily)
3. Update the "Last Updated" date at the top
4. Add version history entry if major changes
5. Commit with descriptive message

## 📚 Additional Resources

**In Repository:**
- `/Jazz Harmony Quiz/README.md` - User-facing documentation
- `/.github/copilot-instructions.md` - GitHub Copilot specific instructions

**External:**
- [Swift Language Guide](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- "The Jazz Theory Book" by Mark Levine (for music theory)

## ❓ Questions?

If you're an AI agent and encounter situations not covered in this documentation:

1. Check the other documentation files
2. Read relevant source code
3. Ask the user for clarification

If you're a human developer:

1. Review the documentation files
2. Check git history for context
3. Reach out to the project maintainer

## 🎵 About This Project

Jazz Harmony Quiz is an iOS educational app that teaches jazz chord theory through interactive quizzes. Built with SwiftUI, it provides a piano keyboard interface for users to practice identifying chord tones across four difficulty levels.

**Key Stats:**
- ~2,900 lines of Swift code
- Pure SwiftUI (iOS 17.0+)
- Zero external dependencies
- 30 chord types across 4 difficulty levels

---

**Last Updated:** 2026-01-10
**Maintained By:** Project contributors
**Format Version:** 1.0
