# 📌 Project Index — Grocery Recipe Manager

## 🧭 Project Vision
A mobile-first application to:
- Maintain a list of staple grocery purchases (auto-populated into weekly lists)
- Build and manage a recipe catalog  
- Track recipe usage frequency and last used date
- Tag recipes with categories like *leftovers* or *quick and easy*

## 🏗️ Architecture & Domain Design

### Domain Boundaries (DDD)
**Bounded Contexts:**
- **Catalog Context**: Recipe, Ingredient, GroceryItem, Tag management with business rules
- **Shopping Context**: WeeklyList, GroceryListItem, list generation, shopping workflows
- **Sharing Context**: CloudKit collaboration, permissions, conflict resolution, family coordination

**Aggregates & Entities:**
- **Recipe** (Aggregate Root) with Ingredient children and usage tracking
- **WeeklyList** (Aggregate Root) with GroceryListItem children and completion state
- **GroceryItem** (Entity) referenced by both aggregates with staple classification

**Value Objects:**
- Quantity (amount + unit), ItemCategory, TagName, RecipeTitle, StapleFlag
- Rule: Make illegal states unrepresentable (e.g., negative quantities, invalid units)

### Technology Decisions
- **iOS-First**: Native SwiftUI with Core Data + CloudKit for family sharing
- **Clean Architecture**: Domain/Application/Infrastructure/Presentation separation
- **MVVM + Clean**: ViewModels depend on Use Cases, not Core Data directly
- **Event-Driven**: Domain events with Combine for loose coupling and coordination
- **Test-Driven**: Domain-first testing strategy with repository contracts

### Mobile Architecture Choice
```
/App
  /Presentation    // SwiftUI Views, ViewModels (MVVM)
  /Application     // Use Cases, DTOs, Application Services
  /Domain          // Entities, Value Objects, Aggregates, Repository Protocols, Domain Services
  /Infrastructure  // Core Data, CloudKit, Concrete Repository Implementations
  /Support         // DI Container, Logging, Utilities
```

**Key Patterns:**
- **Repository Pattern**: Abstract data access behind protocols
- **Use Case/Interactor Pattern**: Encapsulate business operations
- **Domain Events**: Coordinate between bounded contexts
- **Dependency Injection**: Loose coupling between layers

### CloudKit Design Strategy
- **Zones**: Private database for personal data, shared zones for family collaboration
- **CKShare**: Family recipe collections and shared grocery lists
- **Conflict Resolution**: Domain-driven merge policies (last-writer-wins vs business rules)
- **Sync Policy**: Interpret CloudKit conflicts with domain knowledge

## 📂 Repository Structure
- `/docs/requirements/requirements.md` → [Functional & non-functional requirements](docs/requirements/requirements.md)
- `/docs/development/roadmap.md` → [Architecture-driven development roadmap](docs/development/roadmap.md)  
- `/learning-notes/` → Architecture and Core Data learning progression
- `/planning/` → Stories, wireframes, and DDD design decisions
- `/GroceryRecipeManager/` → iOS app implementation with Clean Architecture
- `/project-index.md` → **You are here: canonical architecture & progress tracker**

## 🚦 Current Story Status

### ✅ Completed Stories
- **Story 1.1: Environment Setup** → ✅ Completed 8/16/25
  - Xcode 16.4 environment configured with iOS 18.6 simulators
  - iOS project with Core Data + CloudKit created and functional
  - GitHub repository with professional structure established
  - VS Code configured with Swift development extensions

- **Story 1.2: Core Data Foundation** → ✅ **COMPLETED 8/16/25** 🎉
  - ✅ Complete data model with 6 sophisticated entities
  - ✅ All entity relationships configured and validated
  - ✅ CloudKit integration enabled for family sharing
  - ✅ Sample data system with realistic test data
  - ✅ Core Data classes generated and functional
  - ✅ Working iOS app displaying grocery items with categories
  - ✅ Professional UI with staple indicators and native design
  - ✅ Complete test suite validating all entities (all tests passing ✅)

### 🎯 Next Story  
- **Story 1.3: Clean Architecture Foundation** → ⏳ Ready to Start (PRIORITY SHIFT)
  - Establish Domain layer with entities, value objects, and aggregates
  - Define Repository protocols and Use Case interfaces
  - Implement Domain Services (ListGenerationService, ShoppingHeuristics)
  - Add Domain Events with Combine for coordination
  - Create proper folder structure and dependency injection

### 📅 Upcoming Stories
- **Story 1.4: Repository Implementation & Infrastructure** → ⏳ Planned
- **Story 2.1: Staples CRUD with Clean Architecture** → ⏳ Planned  
- **Story 2.2: List Generation Service & Domain Logic** → ⏳ Planned

👉 Full architecture-driven roadmap in [`docs/development/roadmap.md`](docs/development/roadmap.md)

## 📊 Domain Model Status - ✅ COMPLETE (Infrastructure)

| Entity          | Core Data | Relationships | CloudKit | Domain Model | Use Cases | Repository |
|-----------------|-----------|---------------|-----------|--------------|-----------|------------|
| GroceryItem     | ✅ Complete | ✅ Complete | ✅ Yes   | ⏳ Next     | ⏳ Next  | ⏳ Next   |
| Recipe          | ✅ Complete | ✅ Complete | ✅ Yes   | ⏳ Next     | ⏳ Next  | ⏳ Next   |
| Ingredient      | ✅ Complete | ✅ Complete | ✅ Yes   | ⏳ Next     | ⏳ Next  | ⏳ Next   |
| WeeklyList      | ✅ Complete | ✅ Complete | ✅ Yes   | ⏳ Next     | ⏳ Next  | ⏳ Next   |
| GroceryListItem | ✅ Complete | ✅ Complete | ✅ Yes   | ⏳ Next     | ⏳ Next  | ⏳ Next   |
| Tag             | ✅ Complete | ✅ Complete | ✅ Yes   | ⏳ Next     | ⏳ Next  | ⏳ Next   |

### Domain Services to Implement
- **ListGenerationService**: Generate WeeklyList from staples + selected recipes
- **ShoppingHeuristics**: Merge duplicates, sort by category/aisle, optimize shopping flow
- **RecipeRecommendationService**: Suggest recipes based on available staples
- **UsageTrackingService**: Update recipe usage patterns and analytics

### Use Cases to Implement
- **CreateStaple**, **UpdateStaple**, **RemoveStaple**
- **GenerateWeeklyList**, **UpdateListCompletion**, **OptimizeShoppingOrder**
- **TrackRecipeUsage**, **MarkRecipeAsFavorite**, **SearchRecipesByIngredients**
- **ShareRecipeCollection**, **SyncWithCloudKit**, **ResolveConflicts**

## ✅ Requirements Coverage

| Requirement | Implementation | Status | Domain Service |
|-------------|----------------|--------|----------------|
| Staple grocery list | `GroceryItem.isStaple` + StapleManagementService | ✅ Ready | StapleManagementService |
| Recipe catalog + ingredients | `Recipe` + `Ingredient` entities + RecipeService | ✅ Ready | RecipeManagementService |
| Usage tracking | `Recipe.usageCount` & `lastUsed` + UsageTrackingService | ✅ Ready | UsageTrackingService |
| Tagging system | `Tag` entity + TaggingService | ✅ Ready | TaggingService |
| Weekly list generation | `WeeklyList` + `GroceryListItem` + ListGenerationService | ✅ Ready | ListGenerationService |
| Auto-populate from staples | ListGenerationService with business rules | ⏳ Story 1.4 | ListGenerationService |
| Recipe source URLs | `Recipe.sourceURL` + RecipeImportService | ✅ Ready | RecipeImportService |

👉 Full requirements with DDD language in [`docs/requirements/requirements.md`](docs/requirements/requirements.md)

## 🎯 Technical Achievements

### Infrastructure Layer (Complete ✅)
- **6 sophisticated entities** with proper Core Data design patterns
- **Complex relationship web** supporting grocery-recipe-list workflows  
- **CloudKit compatibility** ready for family sharing features
- **Manual class generation** mastered when automatic methods fail
- **Realistic sample data** demonstrating all entity relationships
- **Complete test suite** validating all entities and data model integrity

### Next: Domain & Application Layers
- **Domain Models**: Rich entities with business rules and invariants
- **Value Objects**: Type-safe, immutable data structures  
- **Repository Contracts**: Clean data access abstractions
- **Use Case Orchestration**: Business logic coordination
- **Domain Events**: Loose coupling between contexts

### Development Workflow Mastery
- **Documentation-Driven Development**: Comprehensive architecture capture
- **Git Workflow**: Professional branching and commit practices
- **Problem-Solving**: Methodical approach to technical challenges
- **Learning Documentation**: Real-time capture of architectural decisions

## 🏆 Architecture Milestones

### ✅ Milestone 1: Infrastructure Foundation (50% Complete)
- ✅ **Story 1.1**: Environment Setup (Complete)
- ✅ **Story 1.2**: Core Data Foundation (Complete)
- 🎯 **Story 1.3**: Clean Architecture Foundation (Ready)
- ⏳ **Story 1.4**: Repository Implementation (Planned)

**Target**: Solid Clean Architecture foundation with proper domain boundaries

### ⏳ Milestone 2: Domain-Driven Features
- **Story 2.1**: Staples CRUD with Use Cases
- **Story 2.2**: List Generation Service  
- **Story 2.3**: Recipe Management with Domain Logic
- **Story 2.4**: Usage Analytics & Insights

### ⏳ Milestone 3: Advanced Architecture  
- **Story 3.1**: CloudKit Sharing with Domain Events
- **Story 3.2**: Conflict Resolution with Business Rules
- **Story 3.3**: Performance Optimization & Caching

## 📚 Learning Journey Documentation

### Completed Learning Modules
- ✅ **Environment Setup**: [`learning-notes/01-environment-setup.md`](learning-notes/01-environment-setup.md)
- ✅ **Xcode & iOS Project**: [`learning-notes/02-xcode-and-ios-project.md`](learning-notes/02-xcode-and-ios-project.md)
- ✅ **Core Data Fundamentals**: [`learning-notes/03-core-data-fundamentals.md`](learning-notes/03-core-data-fundamentals.md)

### Next Learning Modules
- 🎯 **Clean Architecture Patterns**: Domain modeling, Use Cases, Repository pattern
- ⏳ **Domain-Driven Design**: Aggregates, Value Objects, Domain Services
- ⏳ **Advanced SwiftUI**: Feature-oriented architecture with dependency injection

### Skills Developed
- **Core Data & CloudKit expertise** including entity design and relationships
- **SwiftUI fundamentals** with data binding and navigation
- **iOS debugging** with systematic error resolution
- **Professional workflow** with Git integration and documentation

## 🚀 Next Development Session

**Story 1.3 Focus**: Clean Architecture Foundation
- Define Domain models with proper business rules and invariants
- Create Repository protocols and Use Case interfaces
- Implement Domain Services for business logic coordination
- Add Domain Events with Combine for loose coupling
- Establish proper folder structure and dependency injection

**Estimated Duration**: 6-8 hours of focused architecture work
**Key Learning**: Clean Architecture, DDD patterns, iOS dependency injection

---

**Last Updated**: August 16, 2025 - Story 1.2 complete, pivoting to architecture-first approach  
**Major Achievement**: Complete infrastructure foundation ready for Clean Architecture! 🎉

**Status**: 📱 **Functional iOS App** | 🗄️ **Complete Data Model** | ☁️ **CloudKit Ready** | 🧪 **Fully Tested** | 🏗️ **Architecture-Ready**