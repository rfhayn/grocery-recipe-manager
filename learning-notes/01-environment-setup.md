# Learning Notes: Environment Setup

This document describes the development environment setup for the Grocery & Recipe Manager app and tracks key learning concepts.

---

## Prerequisites
- **macOS** with latest version (Big Sur 11.0+ recommended)
- **Apple ID** for App Store and developer account
- **Homebrew** package manager (optional but recommended)
- **GitHub account** for version control

---

## Development Environment Components

### Mobile App Development (iOS - Claude-guided)

#### 1. Xcode Installation & Setup
**Goal**: Set up primary iOS development environment

**Steps Completed:**
- [x] Install Xcode from App Store (14.0+ required)
- [ ] Install Xcode Command Line Tools
- [ ] Configure Xcode preferences
- [ ] Test iOS Simulator

**Commands:**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer
```

**Learning Notes:**
- Xcode is Apple's integrated development environment (IDE)
- Command Line Tools provide Git and build tools
- iOS Simulator allows testing without physical device

#### 2. VS Code Setup (Documentation & Planning)
**Goal**: Secondary editor for project management and documentation

**Steps Completed:**
- [x] Install VS Code
- [x] Install Swift extension
- [x] Install GitLens for enhanced Git features
- [x] Install GitHub integration
- [x] Install Markdown support
- [x] Configure VS Code settings for Swift development

**Extensions Installed:**
- `Swift` (by Swift Server Work Group)
- `GitLens — Git supercharged`
- `GitHub Pull Requests and Issues`
- `Markdown All in One`
- `iOS Common Files`

**Learning Notes:**
- VS Code serves as documentation hub and planning tool
- Swift extension provides syntax highlighting and basic IntelliSense
- Primary development still happens in Xcode

#### 3. Version Control Setup
**Goal**: Professional Git workflow and project tracking

**Steps Completed:**
- [x] Create GitHub repository
- [x] Clone repository locally
- [x] Set up project folder structure
- [x] Configure .gitignore for Swift projects
- [x] Make initial commit with project structure

**Repository Structure:**
```
grocery-recipe-manager-ios/
├── .gitignore              # Swift/iOS specific ignores
├── .vscode/                # VS Code configuration
│   └── settings.json
├── README.md               # Project overview
├── docs/                   # Documentation
│   ├── requirements/
│   ├── design/
│   └── development/
├── learning-notes/         # Learning journey documentation
└── planning/               # Project management
    ├── current-story.md
    ├── stories/
    └── wireframes/
```

**Git Commands Used:**
```bash
# Clone repository
git clone https://github.com/username/grocery-recipe-manager-ios.git

# Navigate to project
cd grocery-recipe-manager-ios

# Check status
git status

# Stage changes
git add .

# Commit changes
git commit -m "Initial project setup with documentation structure"

# Push to GitHub
git push origin main
```

---

## Key Concepts Learned

### Development Workflow
- **Separation of Concerns**: VS Code for planning/docs, Xcode for iOS development
- **Version Control First**: Set up Git repository before writing code
- **Documentation Driven**: Document learning and decisions as you go
- **Incremental Progress**: Small commits with clear messages

### iOS Development Environment
- **Xcode Roles**: IDE, Interface Builder, Simulator, Debugger, App Store deployment
- **Command Line Tools**: Provide Git, build tools, and SDK components
- **iOS Simulator**: Test apps without physical devices during development

### Project Organization
- **Milestone-Based Planning**: Organize work into logical feature groups
- **Story-Driven Development**: Break down milestones into manageable tasks
- **Learning Documentation**: Track concepts and discoveries for future reference

---

## Next Steps

### Immediate (Story 1.1 Completion):
- [ ] Complete Xcode Command Line Tools installation
- [ ] Create new iOS project in Xcode
- [ ] Configure project settings (bundle ID, deployment target)
- [ ] Test app builds and runs in simulator
- [ ] Add Xcode project to Git repository

### Upcoming (Story 1.2):
- [ ] Set up Core Data model
- [ ] Configure app architecture
- [ ] Create basic tab navigation structure

---

## Troubleshooting Notes

### Common Issues:
- **Xcode Command Line Tools**: If `xcode-select --install` fails, try downloading manually from Apple Developer portal
- **Git Configuration**: Ensure Git is configured with your name and email
- **VS Code Swift Extension**: May require Xcode installation to work properly

### Verification Commands:
```bash
# Check Xcode installation
xcode-select -p

# Verify Git configuration
git config --list

# Check VS Code extensions
code --list-extensions
```

---

## Resources Used
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Xcode User Guide](https://developer.apple.com/documentation/xcode)
- [VS Code Swift Extension](https://marketplace.visualstudio.com/items?itemName=swift-server.swift)
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)

---

## Questions & Discoveries

### Questions That Came Up:
- Why use both VS Code and Xcode? (Answer: Different strengths for different tasks)
- What's the difference between Xcode and Command Line Tools? (Answer: CLI tools are subset for terminal/build operations)
- How to organize learning documentation? (Answer: Separate notes for each major topic/milestone)

### Key Discoveries:
- Project structure matters from day one
- Documentation is as important as code
- Git workflow should be established early
- Learning should be documented for future reference

### Future Learning Goals:
- Xcode interface and navigation
- Swift language fundamentals
- SwiftUI basics and architecture
- Core Data concepts and implementation
- iOS app lifecycle and best practices

---

**Status**: Environment setup ✅ complete, ready for iOS project creation