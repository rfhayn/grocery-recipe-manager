# Grocery & Recipe Manager iOS App

A comprehensive iOS application for managing grocery lists, recipes, and staple items with family sharing capabilities.

## 🎯 Project Goals
- Build a practical family grocery management app
- Learn iOS development with SwiftUI and Core Data
- Implement CloudKit for real-time family collaboration
- Create a portfolio-worthy iOS project demonstrating modern iOS development practices

## 🛠️ Tech Stack
- **Platform**: iOS 14.0+
- **Framework**: SwiftUI
- **Data**: Core Data + CloudKit
- **Language**: Swift 5.0+
- **Architecture**: MVVM with Clean Architecture principles

## 📱 Core Features

### Milestone 1: MVP (Grocery Automation) ✅ In Progress
- [ ] Staples management (recurring grocery items)
- [ ] Auto-populate weekly grocery lists
- [ ] Core Data persistence layer
- [ ] Basic iOS app structure

### Milestone 2: Recipe Integration
- [ ] Recipe catalog with ingredients and instructions
- [ ] Recipe → grocery list pipeline
- [ ] Recipe creation and editing interface

### Milestone 3: Usage Insights
- [ ] Track recipe usage frequency and dates
- [ ] Display "most used" and "recently used" recipes
- [ ] Usage analytics and insights

### Milestone 4: Tagging & Discovery
- [ ] Recipe tagging system ("leftovers", "quick & easy")
- [ ] Advanced search and filtering
- [ ] Recipe discovery features

### Milestone 5: Cloud Integration
- [ ] CloudKit synchronization across devices
- [ ] Family sharing and collaborative editing
- [ ] Offline-first functionality

### Future Enhancements
- [ ] Meal planning calendar
- [ ] Photo support for recipes
- [ ] Smart suggestions and recommendations
- [ ] Nutritional information tracking

## 🚀 Getting Started

### Prerequisites
- **macOS** Big Sur 11.0+ 
- **Xcode** 14.0+ (available from App Store)
- **Apple Developer Account** (free tier sufficient for development)
- **Git** and **GitHub** account

### Development Environment
This project uses a dual-environment approach:
- **Xcode**: Primary iOS development, interface design, debugging
- **VS Code**: Documentation, project planning, learning notes

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/grocery-recipe-manager-ios.git
   cd grocery-recipe-manager-ios
   ```

2. **Install Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```

3. **Open project in Xcode** (once iOS project is created):
   ```bash
   open GroceryApp.xcodeproj
   ```

## 📋 Development Progress

**Current Status**: Milestone 1, Story 1.3 - Staples Management (CRUD)

### ✅ Completed Stories:
- **Story 1.1: Environment Setup** (Completed 8/16/25)
  - [x] GitHub repository with professional structure
  - [x] VS Code configured with iOS development extensions
  - [x] Xcode 16.4 installed with iOS 18.6 simulators
  - [x] iOS project created with Core Data + CloudKit enabled
  - [x] Project builds and runs successfully in simulator

- **Story 1.2: Core Data Foundation** (Completed 8/16/25)
  - [x] Sophisticated Core Data model designed and implemented
  - [x] 6 entities created: GroceryItem, Recipe, Ingredient, GroceryList, GroceryListItem, Tag
  - [x] CloudKit integration configured for family sharing
  - [x] Core Data classes generated manually (learned troubleshooting)
  - [x] Realistic sample data with automatic loading
  - [x] Working iOS app with data persistence verified

### 🎯 In Progress:
- **Story 1.3: Staples Management (CRUD)** - Starting next
  - Building complete staples management interface
  - Implementing CRUD operations with SwiftUI
  - Adding search and filtering capabilities

### 📊 Milestone 1 Progress: 2/4 Stories Complete (50%)

See detailed progress in:
- [Development Roadmap](docs/development/roadmap.md) - Milestone breakdown with stories
- [Current Story Status](planning/current-story.md) - Active development tracking
- [Requirements Document](docs/requirements/requirements.md) - Complete feature specifications

## 🎓 Learning Journey

This project documents a comprehensive iOS development learning path:

### Learning Resources
- [Environment Setup](learning-notes/01-environment-setup.md) - Development environment configuration
- [iOS Development Concepts](learning-notes/) - Ongoing learning documentation
- [Architecture Decisions](docs/design/) - Design and architectural choices

### Key Learning Areas
- **SwiftUI fundamentals** and modern iOS UI development
- **Core Data** for local persistence and data management
- **CloudKit integration** for cloud sync and sharing
- **iOS app architecture** and best practices
- **Version control** and professional development workflows

## 🏗️ Project Structure

```
grocery-recipe-manager-ios/
├── README.md                    # Project overview (this file)
├── docs/                        # Documentation
│   ├── requirements/            # Feature requirements and specifications
│   ├── design/                  # Architecture and design decisions
│   └── development/             # Development roadmaps and guides
├── planning/                    # Project management
│   ├── current-story.md         # Active development tracking
│   ├── stories/                 # Completed story documentation
│   └── wireframes/              # UI mockups and designs
├── learning-notes/              # Learning journey documentation
├── .vscode/                     # VS Code configuration
└── [iOS Project Files]          # Xcode project (to be created)
```

## 🤝 Development Approach

### Methodology
- **Milestone-driven development** with clear feature groupings
- **Story-based tasks** with specific acceptance criteria
- **Learning-focused progression** building iOS skills incrementally
- **Documentation-first approach** capturing decisions and discoveries

### Collaboration
This project involves collaboration between:
- **iOS Development** (Claude-guided): SwiftUI, Core Data, CloudKit implementation
- **System Architecture** (ChatGPT-guided): Clean architecture, backend design patterns
- **Learning Documentation**: Comprehensive knowledge capture throughout development

## 📊 Success Metrics

### Technical Goals
- **Working iOS app** with core grocery management features
- **Cloud synchronization** enabling family collaboration
- **Professional code quality** suitable for portfolio demonstration
- **Comprehensive documentation** of development journey

### Learning Objectives
- **iOS Development Proficiency**: SwiftUI, Core Data, CloudKit
- **Software Architecture**: Clean code principles and design patterns
- **Development Workflow**: Git, documentation, project management
- **Problem-Solving**: Real-world app development challenges

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Related Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)

---

**Ready to build something amazing? 🚀**

*Last updated: 08/16/25 4:30p EDT - Milestone 1 in progress*