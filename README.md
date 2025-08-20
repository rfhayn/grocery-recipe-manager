# Grocery & Recipe Manager iOS App

A comprehensive iOS application for managing grocery lists, recipes, and staple items with family sharing capabilities and personalized store-layout optimization.

## 🎯 Project Goals
- ✅ Build a practical family grocery management app
- ✅ Learn iOS development with SwiftUI and Core Data
- ✅ Implement CloudKit for real-time family collaboration
- ✅ Create a portfolio-worthy iOS project demonstrating modern iOS development practices
- ✅ **Achieve personalized store-layout optimization for efficient grocery shopping**

## 🛠️ Tech Stack
- **Platform**: iOS 14.0+
- **Framework**: SwiftUI
- **Data**: Core Data + CloudKit
- **Language**: Swift 5.0+
- **Architecture**: MVVM with Clean Architecture principles
- **Development**: Xcode 16.4, iOS 18.6 Simulators

## 📱 Core Features

### ✅ Milestone 1: MVP (Grocery Automation) - 100% Complete 🎉
- ✅ **Sophisticated data model** with 7 Core Data entities and CloudKit integration
- ✅ **Performance-optimized architecture** with background operations and indexed queries
- ✅ **Production-quality staples management** with store-layout optimization *(Story 1.3 Complete)*
- ✅ **Dynamic category management** with custom sort order and drag-and-drop reordering *(Story 1.3.5 Complete)*
- ⏳ **Auto-populate weekly grocery lists** from selected staples with custom category organization *(Story 1.4 Ready)*

### Milestone 2: Recipe Integration
- [ ] Recipe catalog with ingredients and instructions
- [ ] Recipe → grocery list pipeline with dynamic category integration
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
- **Xcode** 14.0+ (current: Xcode 16.4)
- **Apple Developer Account** (free tier sufficient for development)
- **Git** and **GitHub** account

### Development Environment
This project uses a dual-environment approach:
- **Xcode**: Primary iOS development, interface design, debugging
- **VS Code**: Documentation, project planning, learning notes

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/rfhayn/grocery-recipe-manager.git
   cd grocery-recipe-manager
   ```

2. **Install Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```

3. **Open project in Xcode:**
   ```bash
   open GroceryRecipeManager/GroceryRecipeManager.xcodeproj
   ```

4. **Build and run** (`Cmd+R`) - app should launch with sample data

## 📋 Development Progress

**Current Status**: 🏆 **Milestone 1: 100% Complete** | 📋 **Ready for Story 1.4**

### 🎉 Major Achievements Completed:

**✅ Story 1.1: Environment Setup** (Completed 8/16/25)
- [x] GitHub repository with professional structure
- [x] VS Code configured with iOS development extensions  
- [x] Xcode 16.4 installed with iOS 18.6 simulators
- [x] iOS project created with Core Data + CloudKit enabled
- [x] Project builds and runs successfully in simulator

**✅ Story 1.2: Core Data Foundation** (Completed 8/18/25)
- [x] **Sophisticated data model** with 7 entities and complex relationships
- [x] **Complete entity design**: GroceryItem, Recipe, Ingredient, WeeklyList, GroceryListItem, Tag, Category
- [x] **CloudKit integration** configured for family sharing
- [x] **All entity relationships** properly configured with inverse relationships
- [x] **Core Data classes** generated manually (mastered advanced troubleshooting)
- [x] **Comprehensive sample data** with realistic grocery items, recipes, and relationships
- [x] **Working iOS app** with professional UI displaying grocery items with categories

**✅ Story 1.2.5: Core Data Performance & Architecture** (Completed 8/19/25)
- [x] **Database optimization** with compound indexes for frequently queried attributes
- [x] **Background processing** with non-blocking Core Data operations
- [x] **Professional error handling** with user-friendly error messages and recovery
- [x] **Production safety** with DEBUG conditionals and proper build configurations
- [x] **Performance foundation** ready for complex features

**✅ Story 1.3: Professional Staples Management** (Completed 8/20/25)
- [x] **Complete CRUD interface** with professional add, edit, delete, search functionality
- [x] **Smart duplicate resolution** with never-block workflow and convert/edit options
- [x] **Store-layout categories** with 6-category system optimized for grocery shopping
- [x] **Professional iOS interactions** with context menus, swipe actions, accessibility
- [x] **Real-time search & filtering** performance-optimized with indexed queries
- [x] **Visual excellence** with category icons, purchase indicators, loading/empty states

**✅ Story 1.3.5: Dynamic Category Management** (Completed 8/20/25) 🎉
- [x] **Complete transition** from hardcoded to dynamic category system with zero data loss
- [x] **Custom sort order** with professional drag-and-drop reordering for store layout optimization
- [x] **Seamless migration** with duplicate cleanup and validation framework
- [x] **Cross-app integration** with custom order applied to StaplesView, forms, and future lists
- [x] **Professional polish** with native iOS interactions, error handling, and visual feedback

### 🎯 Next Development: Story 1.4 Enhanced

**⏳ Story 1.4: Auto-Populate Grocery Lists with Selective Inclusion (3-4 hours)**
- **Enhanced requirements**: Checkbox control in StaplesView for granular list generation
- **Custom category sections**: Generated lists organized by personal store layout order
- **Shopping workflow**: Check-off functionality and completion tracking
- **Multiple list management**: Support concurrent grocery lists with source tracking
- **Store optimization**: Lists follow custom category order for efficient shopping navigation

### 📊 Progress Metrics:
- **Milestone 1 Progress**: 100% complete (5/5 stories) 🎉
- **Core Data Foundation**: 7/7 entities complete with dynamic relationships ✅
- **Performance Optimization**: Background operations and indexed queries ✅
- **CloudKit Preparation**: 100% ready for family sharing ✅
- **Professional Interface**: App Store-quality staples management with dynamic categories ✅
- **Sample Data**: Comprehensive test scenarios with dynamic category system ✅

## 🎓 Learning Journey

This project documents a comprehensive iOS development learning path:

### ✅ Completed Learning Modules
- [Environment Setup](learning-notes/01-environment-setup.md) - Development environment configuration
- [Xcode & iOS Project Setup](learning-notes/02-xcode-and-ios-project.md) - iOS project creation and configuration
- [Core Data Fundamentals](learning-notes/03-core-data-fundamentals.md) - Complex entity design and relationships
- [MacBook Air Setup & Recreation](learning-notes/04-macbook-error-setup-and-recreation.md) - Cross-computer development
- [Story 1.3 Foundation](learning-notes/05-story-1-3-staples-foundation.md) - Basic staples interface
- [Performance & Architecture](learning-notes/06-story-1-2-5-core-data-performance-and-architecture.md) - Optimization
- [Professional Staples Management](learning-notes/07-story-1-3-professional-staples-management.md) - Complete CRUD
- [Dynamic Category Management](learning-notes/08-story-1-3-5-dynamic-category-management.md) - Migration & drag-and-drop ✅

### 🧠 Skills Developed
- **Xcode Proficiency**: Project management, simulators, interface navigation, debugging
- **Core Data Expertise**: Entity design, complex relationships, CloudKit integration, performance optimization, migration strategies
- **SwiftUI Mastery**: Data binding, navigation, list management, professional form design, advanced interactions, drag-and-drop
- **iOS Design Patterns**: Background processing, error handling, accessibility, professional polish
- **Professional Workflow**: Git integration, documentation practices, cross-computer development
- **Performance Optimization**: Indexed queries, background contexts, predicate-based filtering
- ✅ **Advanced SwiftUI**: Context menus, swipe actions, sheet management, real-time search, drag-and-drop reordering
- ✅ **User Experience Design**: Smart duplicate resolution, empty states, visual feedback, store-layout optimization
- ✅ **Dynamic Data Management**: Core Data relationships, migration strategies, schema evolution
- ✅ **Professional Migration**: Dual-field approach, zero data loss, duplicate cleanup

### 📚 Next Learning Areas
- **Selective Data Control**: Checkbox-based inclusion systems with bulk operations (Story 1.4)
- **List Generation Algorithms**: Auto-population logic and workflow optimization (Story 1.4)
- **Shopping Workflow UX**: Check-off functionality and completion tracking (Story 1.4)
- **Recipe Integration**: Complex ingredient-staple relationships with dynamic categories (Story 2.x)
- **CloudKit Activation**: Real-time sync and collaborative features

## 🏗️ Project Architecture

### Data Model (Complete ✅)
```
Recipe ←→ Ingredient ←→ GroceryItem
Recipe ←→ Tag (many-to-many)
Recipe → GroceryListItem
WeeklyList ←→ GroceryListItem ←→ GroceryItem
GroceryListItem → Recipe (sourceRecipe)
Category ←→ GroceryItem (dynamic relationship)
```

**Entities:**
- **GroceryItem**: Core entity for staples and individual groceries with dynamic category relationships
- **Category**: Dynamic category system with custom sort order for store layout optimization
- **Recipe**: Recipe storage with usage tracking and source URLs
- **Ingredient**: Bridge between recipes and grocery items with quantities
- **WeeklyList**: Container for weekly shopping lists
- **GroceryListItem**: Individual items in shopping lists with completion status
- **Tag**: Recipe categorization with many-to-many relationships

### Technology Stack
- **Core Data + CloudKit**: Sophisticated local persistence with cloud sync preparation and dynamic data management
- **SwiftUI**: Modern declarative UI framework with professional interactions and drag-and-drop
- **Performance Architecture**: Background operations, indexed queries, professional error handling
- **Migration Framework**: Proven patterns for safe schema evolution and continuous app development
- **Professional Polish**: Accessibility, loading states, visual feedback, App Store quality

## 🏆 Technical Achievements

### Story 1.3.5: Dynamic Category Management with Store-Layout Optimization 🎉
- **Complete Dynamic System**: Transition from hardcoded to Core Data categories with zero data loss
- **Custom Sort Order**: Professional drag-and-drop reordering for personal store layout optimization
- **Seamless Migration**: Dual-field migration strategy with duplicate cleanup and validation
- **Cross-App Integration**: Custom order immediately applied to StaplesView, forms, and future grocery lists
- **Professional Polish**: Native iOS drag-and-drop with proper error handling and visual feedback

### Story 1.3: Production-Quality Staples Management
- **Complete CRUD Interface**: Professional add, edit, delete, search with smart duplicate resolution
- **Store-Layout Categories**: Dynamic category system optimized for grocery shopping efficiency
- **Professional iOS Interactions**: Context menus, swipe actions, accessibility support
- **Real-Time Search & Filtering**: Performance-optimized with indexed queries
- **Visual Excellence**: Category icons, purchase indicators, loading states, empty states
- **Background Processing**: Non-blocking operations with professional error handling

### Core Data & CloudKit Mastery
- **7 sophisticated entities** with proper Core Data design patterns and dynamic relationships
- **Complex relationship web** supporting grocery-recipe-list workflows with category integration  
- **CloudKit compatibility** ready for family sharing features with all entities configured
- **Performance optimization** with compound indexes and background operations
- **Professional error handling** with user-facing messages and recovery patterns
- **Migration excellence** with proven dual-field strategy for safe schema evolution
- **Production safety** with DEBUG conditionals and proper build configurations

### iOS Development Skills
- **Advanced SwiftUI**: Context menus, swipe actions, sheet presentation, real-time search, drag-and-drop
- **Professional UI Design**: App Store-quality interface with native iOS interactions and dynamic data
- **Performance-Conscious Development**: Indexed queries, background contexts, and migration strategies
- **User Experience Excellence**: Smart duplicate resolution, visual feedback, accessibility, store-layout optimization
- **Dynamic Data Architecture**: Flexible systems supporting user customization and personalization

### Development Workflow Mastery
- **Documentation-Driven Development**: Comprehensive learning capture throughout process
- **Professional Git Workflow**: Feature branches, detailed commits, cross-computer development
- **Architecture Decision Making**: Systematic approach to technical improvements and migration strategies
- **Learning Documentation**: Real-time capture of discoveries and solutions
- **Migration Excellence**: Proven patterns for safe schema evolution and rollback capability

## 🤝 Development Approach

### Methodology
- **Milestone-driven development** with clear feature groupings and measurable outcomes
- **Story-based tasks** with specific acceptance criteria and learning objectives
- **Learning-focused progression** building iOS skills incrementally with real projects
- **Documentation-first approach** capturing decisions, discoveries, and technical knowledge
- **Migration-conscious development** with patterns for continuous app evolution

### Collaboration Framework
This project demonstrates collaboration between specialized AI assistants:
- **iOS Development** (Claude-guided): SwiftUI, Core Data, CloudKit implementation
- **System Architecture** (ChatGPT-guided): Clean architecture patterns and backend design
- **Comprehensive Documentation**: Knowledge capture and project coordination

## 📊 Success Metrics

### ✅ Technical Goals Achieved
- **Production-quality iOS app** with professional staples management and dynamic category system
- **App Store-ready code quality** suitable for portfolio demonstration  
- **Sophisticated data architecture** supporting complex grocery and recipe workflows with user customization
- **CloudKit foundation** enabling future family collaboration features
- **Performance optimization** with background operations, indexed queries, and migration framework
- **Dynamic data management** supporting unlimited user customization and store-layout optimization

### ✅ Learning Objectives Met
- **iOS Development Proficiency**: SwiftUI mastery, Core Data expertise, CloudKit integration, drag-and-drop
- **Professional iOS Patterns**: Background processing, error handling, accessibility compliance, migration strategies
- **Software Architecture Understanding**: Clean code principles, performance optimization, schema evolution
- **Development Workflow Mastery**: Git management, documentation practices, systematic problem-solving
- **Real-World Problem-Solving**: Technical debugging, user experience design, store-layout optimization
- **Migration Excellence**: Safe schema evolution patterns and zero data loss transitions

### 🎯 Upcoming Goals
- **Enhanced List Generation**: Auto-populate grocery lists with selective inclusion and custom category organization (Story 1.4)
- **Recipe Integration**: Complete ingredient-staple relationships leveraging dynamic category system (Story 2.x)
- **Cloud Activation**: Real-time family sharing and collaborative editing (Milestone 5)
- **App Store Readiness**: Professional polish and deployment preparation

## 🔧 Development Setup

### Project Structure
```
grocery-recipe-manager/
├── README.md                        # Project overview (this file)
├── project-index.md                 # Progress tracking and coordination
├── docs/                            # Documentation
│   ├── requirements/                # Feature requirements and specifications
│   ├── design/                      # Architecture and design decisions
│   └── development/                 # Development roadmaps and guides
├── planning/                        # Project management
│   ├── current-story.md             # Active development tracking
│   ├── stories/                     # Completed story documentation
│   └── wireframes/                  # UI mockups and designs
├── learning-notes/                  # Learning journey documentation
├── .vscode/                         # VS Code configuration
└── GroceryRecipeManager/            # iOS Xcode project
    ├── GroceryRecipeManager.xcodeproj
    ├── GroceryRecipeManager/        # App source code
    ├── GroceryRecipeManagerTests/
    └── GroceryRecipeManagerUITests/
```

### Quick Start Commands
```bash
# Clone and navigate
git clone https://github.com/rfhayn/grocery-recipe-manager.git
cd grocery-recipe-manager

# Open in Xcode and build
open GroceryRecipeManager/GroceryRecipeManager.xcodeproj
# Press Cmd+R to build and run

# View documentation in VS Code
code .
```

## 📱 Current App Features

### ✅ Working Features (Production Quality)
- **Production-Quality Staples Management**: Complete CRUD with smart duplicate resolution
- **Dynamic Category System**: User-customizable categories with professional drag-and-drop reordering
- **Store-Layout Optimization**: Categories orderable to match personal shopping patterns and store traversal
- **Real-Time Search & Filtering**: Performance-optimized with indexed queries and dynamic category filtering
- **Professional iOS Interactions**: Context menus, swipe actions, accessibility support, visual feedback
- **Visual Shopping Intelligence**: Purchase history indicators, category grouping, and custom organization
- **Background Operations**: Non-blocking saves with professional error handling and loading states
- **Migration Excellence**: Seamless transition to dynamic categories with zero data loss and duplicate cleanup
- **Sample Data**: Realistic grocery items demonstrating all functionality with dynamic category system
- **CloudKit Preparation**: All 7 entities configured for future family sharing

### 📋 Coming Next (Story 1.4)
**Auto-Populate Grocery Lists with Selective Inclusion (3-4 hours)**
- **Selective Inclusion**: Checkbox control in StaplesView for granular list generation
- **Custom Category Sections**: Lists organized by personal store layout order
- **Shopping Workflow**: Check-off functionality with completion tracking and progress indicators
- **Multiple List Management**: Support concurrent grocery lists with source tracking
- **Store Optimization**: Generated lists follow custom category order for efficient shopping navigation

### 🚀 Enhanced Future Features (Post-Story 1.4)
- **Recipe Integration**: Link ingredients to staples with dynamic category consistency
- **Family Sharing**: CloudKit sync for collaborative grocery management with shared categories
- **Usage Analytics**: Shopping patterns and staple optimization insights
- **Smart Suggestions**: Personalized recommendations based on purchase history and store layout

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Related Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)

---

## 🎉 Current Achievement

**Status**: 🏆 **Milestone 1: 100% Complete** | 🎉 **Story 1.3.5 Complete** | ⚡ **Performance-Optimized** | 🏪 **Store-Layout Optimized** | 🔄 **Dynamic Category System**

**Major Milestone**: **Complete MVP staples management with dynamic category system and personalized store-layout optimization!**

**Story 1.3.5 Achievement**: 
- **Dynamic Category System**: Complete transition from hardcoded to dynamic with zero data loss
- **Store-Layout Optimization**: Professional drag-and-drop reordering for personal shopping efficiency  
- **Professional iOS Patterns**: Native drag-and-drop interactions with accessibility and visual feedback
- **Migration Excellence**: Proven framework for future schema evolution and complex data transitions
- **Cross-App Integration**: Custom category order immediately applied throughout entire application

**Next Priority**: **Story 1.4 Enhanced Auto-Populate Grocery Lists** with selective inclusion and custom category organization for maximally efficient grocery shopping experience! 🛒✨

**Ready to complete the MVP grocery automation with personalized store optimization? 🚀**

*Last updated: 08/20/25 - Story 1.3.5 dynamic category management complete, Milestone 1 achieved, advancing to Story 1.4 enhanced development*