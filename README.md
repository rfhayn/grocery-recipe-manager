# Forager

An iOS app that transforms grocery shopping from a time-consuming chore into an efficient, personalized experience through smart automation, custom store layouts, and intelligent meal planning.

## Features

### Core Functionality
- **Smart Grocery Lists**: Auto-generate weekly shopping lists from your regular staples
- **Custom Store Layout**: Organize items by your actual shopping path for maximum efficiency
- **Recipe Management**: Build and maintain a personal recipe collection with usage tracking
- **Calendar Meal Planning**: Plan meals across multiple weeks with an intuitive calendar interface
- **Intelligent Categories**: Create unlimited custom categories with personalized drag-and-drop ordering
- **Real-time Search**: Instant search across all items and recipes

### Advanced Features
- **Meal Plan Integration**: Assign recipes to specific days and bulk-add all ingredients to your shopping list
- **Recipe Source Tracking**: See which recipes contributed ingredients to your shopping list
- **Recipe Scaling**: Adjust servings with automatic ingredient quantity conversion and kitchen-friendly fractions
- **Quantity Consolidation**: Intelligently merge duplicate items (e.g., "1 cup milk" + "2 cups milk" = "3 cups milk")
- **Unit Conversion**: Automatic conversion between compatible units (cups ↔ tablespoons ↔ teaspoons, pounds ↔ ounces)
- **Recipe Usage Analytics**: Track recipe usage patterns with automatic counting and dating
- **Meal Completion Tracking**: Mark meals as completed with visual feedback
- **Performance Optimized**: Sub-500ms response times with Core Data optimization

### Intelligent Automation
- **Parse-Then-Autocomplete**: Smart ingredient entry with fuzzy matching and template alignment
- **Ingredient Normalization**: Automatic deduplication (e.g., "Butter", "butter", "BUTTER" → "butter")
- **Template System**: Single source of truth for ingredients prevents duplication across recipes
- **Smart Consolidation**: Reduce list redundancy by 30-50% through intelligent merging

## Screenshots

*Coming soon - Screenshots of the main tabs and key features*

## Getting Started

### Requirements
- iOS 18.5+
- Xcode 15.0+
- macOS Sonoma 14.0+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/rfhayn/forager.git
cd forager
```

2. Open the project in Xcode:
```bash
open forager.xcodeproj
```

3. Build and run:
   - Select your target device or simulator
   - Press ⌘+R to build and run
   - The app launches ready for use

## App Structure

The app consists of four main tabs:

- **Lists**: View and manage weekly grocery lists with smart consolidation and recipe source tracking
- **Recipes**: Browse and manage your recipe collection with search, scaling, and usage analytics
- **Meal Planning**: Calendar-based meal planning with recipe assignments and bulk grocery list generation
- **Settings**: User preferences, category management, display options, and help documentation

## Architecture

### Technology Stack
- **SwiftUI** for modern, declarative UI
- **Core Data** for local data persistence with performance optimization
- **CloudKit** ready for family sharing (planned for M5.1)

### Data Model
- 9-entity Core Data model supporting recipes, ingredients, meal planning, and custom categories
- Performance-optimized queries with compound indexes
- Template-based ingredient normalization to prevent duplication
- Structured quantity system enabling scaling and consolidation
- Meal planning with date-based recipe assignments
- Many-to-many relationships for recipe source tracking

**Core Entities:**
- WeeklyList, GroceryListItem, Category
- Recipe, Ingredient, IngredientTemplate
- MealPlan, PlannedMeal, UserPreferences

### Performance
- **Sub-millisecond response times** for most operations
- **Background processing** for non-blocking UI operations
- **Memory efficient** relationship handling
- **Validated performance targets**: All operations < 0.5s maintained across 85+ hours of development

## Development Status

### Completed Milestones (85.75 hours)

**M1: Professional Grocery Management** ✅ (32 hours - August 2025)
- Custom store-layout optimization with drag-and-drop categories
- Staple item system with auto-population
- Professional iOS UI with Core Data architecture
- Sub-0.1s query performance

**M2: Recipe Integration** ✅ (16.5 hours - Sept-Oct 2025)
- Complete recipe catalog with CRUD operations
- Recipe-to-grocery integration with intelligent templating
- Recipe ingredient autocomplete with fuzzy matching
- Enhanced search across name, ingredients, tags, instructions

**M3: Structured Quantity Management** ✅ (10.5 hours - October 2025)
- Recipe scaling with kitchen-friendly fractions (0.25x-4x)
- Intelligent quantity consolidation (30-50% list reduction)
- Unit conversion system (volume and weight)
- Visual indicators for parseable vs. unparseable quantities

**M3.5: Foundation Validation** ✅ (8.5 hours - October 2025)
- Comprehensive validation and test infrastructure
- 75+ computed properties for data integrity
- Automated validation test suite (6 test suites, 100% pass rate)
- Performance validation (all operations < 0.5s)

**M4: Meal Planning & Enhanced Grocery Integration** ✅ (18.25 hours - Oct-Nov 2025)
- **M4.1**: Settings infrastructure with user preferences (1.5h)
- **M4.2**: Calendar-based meal planning with recipe assignment (4h)
- **M4.3.1**: Recipe source tracking with many-to-many relationships (3.5h)
- **M4.3.2**: Scaled recipe to shopping list with servings adjustment (1.25h)
- **M4.3.3**: Bulk add from meal plan with progress tracking (2.5h)
- **M4.3.4**: Meal completion tracking with visual feedback (1h)

**M5.0: App Renaming & Directory Restructure** ✅ (November 2025)
- Complete app rename from "GroceryRecipeManager" to "Forager"
- Directory structure flattened and optimized
- All documentation and references updated
- 164 references updated across 74 files

### Planned Features

**M5.1: TestFlight & Production Infrastructure** (8-12 hours)
- Apple Developer Account setup & App Store Connect configuration
- TestFlight deployment & real device testing (3+ devices)
- Production build preparation

**M5.2: CloudKit Sync** (12-15 hours)
- CloudKit schema design & sync engine implementation
- Family sharing features with real-time collaboration
- Multi-device support with conflict resolution

**M6: Testing Foundation & AI Augmentation** (12-18 hours)
- Human-written test baseline (50%+ service coverage)
- AI test reviewer operational on every PR via GitHub Actions
- Testing standards documentation and CI/CD pipeline
- Semantic coverage gap detection foundation

**M7-M11: Advanced Intelligence Platform** (26-38 hours)
- **M7**: Analytics & Insights dashboard
- **M8**: Nutrition tracking with Apple Health integration
- **M9**: Budget intelligence and cost optimization
- **M10**: AI-powered recipe assistant
- **M11**: Lifestyle optimization features

## Project Structure

```
forager/
├── forager.xcodeproj          # Xcode project
├── forager/                    # Main source code
│   ├── Views/                  # SwiftUI views
│   ├── Services/               # Data services
│   └── forager.xcdatamodeld/   # Core Data model
├── foragerTests/               # Unit tests
├── foragerUITests/             # UI tests
├── docs/                       # Comprehensive documentation
│   ├── requirements.md         # All functional requirements
│   ├── roadmap.md              # Milestone timeline & tracking
│   ├── current-story.md        # Active development status
│   ├── project-index.md        # Documentation navigation hub
│   ├── learning-notes/         # Implementation journey
│   ├── architecture/           # Architecture Decision Records
│   └── prds/                   # Product Requirements Documents
└── Tools/                      # Development tools
    └── AITestReview/           # AI test review CLI (M6)
```

## Documentation

This project maintains extensive documentation tracking the complete development journey:

- **[requirements.md](docs/requirements.md)** - All functional requirements with traceability to implementation
- **[roadmap.md](docs/roadmap.md)** - Milestone sequence, timelines, and completion tracking
- **[current-story.md](docs/current-story.md)** - Current active development status
- **[project-index.md](docs/project-index.md)** - Central navigation hub for all documentation
- **[learning-notes/](docs/learning-notes/)** - Detailed implementation notes for each milestone
- **[architecture/](docs/architecture/)** - Architecture Decision Records (ADRs)
- **[prds/](docs/prds/)** - Product Requirements Documents for complex features

## Contributing

This is a personal learning project focused on iOS development skills and best practices. The extensive documentation in the `docs/` folder tracks the complete development journey, architectural decisions, and lessons learned.

### Development Approach
- **Incremental Development**: Features built in small, validated phases
- **Performance First**: All features maintain strict performance standards (<0.5s)
- **User Experience Focus**: Native iOS patterns and accessibility compliance
- **Quality Assurance**: Comprehensive validation and testing after each phase
- **Documentation-Driven**: Every decision and pattern documented for future reference

### Planning Accuracy
- **88% average accuracy** across completed milestones (M1-M4)
- **100% build success rate** (zero breaking changes)
- **Phase-based planning** with 45-90 minute increments
- **Proven patterns** reused across milestones for velocity

## Technical Highlights

### Performance Engineering
- N+1 query prevention with batch relationship fetching
- Indexed Core Data queries for instant search results (<0.1s)
- Background operations preventing UI blocking
- Optimized parsing service (<0.03s for quantity parsing)
- Consolidation analysis <0.3s for 50+ items

### User Experience Innovation
- Revolutionary custom store layout optimization
- Drag-and-drop category personalization
- Recipe source tracking with tappable navigation
- Progress overlays for long-running operations
- Visual feedback throughout (checkmarks, strikethrough, scale indicators)

### Architecture Excellence
- Service-oriented architecture with clear separation of concerns
- Template-based normalization preventing data duplication
- Structured quantity system enabling advanced features
- Scalable data model supporting future intelligence platform
- Performance monitoring and validation systems
- Comprehensive computed properties for data integrity

### Code Quality
- **Zero technical debt** maintained across 85+ hours
- Consistent naming conventions (M#.#.# hierarchy)
- Comprehensive inline documentation explaining "why" not "what"
- Function header comments for all methods
- MARK comments for logical section organization

## Performance Metrics

All targets met or exceeded across 85+ hours of development:

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Query performance | < 0.1s | < 0.1s | ✅ Met |
| Search performance | < 0.2s | < 0.15s | ✅ Exceeded |
| Autocomplete | < 0.1s | < 0.08s | ✅ Exceeded |
| Parsing | < 0.05s | < 0.03s | ✅ Exceeded |
| Recipe scaling | < 0.5s | < 0.4s | ✅ Exceeded |
| Consolidation analysis | < 0.5s | < 0.3s | ✅ Exceeded |
| Merge execution | < 1s | < 0.8s | ✅ Exceeded |
| UI responsiveness | 60fps | 60fps | ✅ Met |

## Learning Journey

This project represents a comprehensive learning journey in iOS development, including:

- **Core Data**: Advanced features including relationships, migrations, performance optimization
- **SwiftUI**: Modern declarative UI with complex state management patterns
- **Architecture**: Service layer design, data model planning, scalability considerations
- **Performance**: Query optimization, background processing, memory management
- **UX Design**: Native iOS patterns, accessibility, visual feedback systems
- **Project Management**: Phase-based planning, accurate estimation, documentation practices

## License

This project is available under the MIT License.

## Contact

For questions about the project or iOS development approaches used, please open an issue or check the comprehensive documentation in the `docs/` folder.

---

**Project Stats:**
- 🕐 85.75+ hours of development across 5 major milestones
- 📊 88% planning accuracy with phase-based approach
- ✅ 100% build success rate (zero breaking changes)
- 🚀 100% performance targets met or exceeded
- 📚 Comprehensive documentation tracking every decision

*Transform your grocery shopping experience with intelligent automation and personalized organization.*
