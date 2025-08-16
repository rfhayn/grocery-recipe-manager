# Grocery & Recipe Manager - Development Roadmap

## 🎯 Learning Goals
By the end of this project, you'll understand:
- iOS app structure and SwiftUI fundamentals
- Core Data for local storage
- CloudKit for cloud sync and sharing
- App architecture and best practices
- iOS deployment and App Store preparation

---

## 📚 Phase 1: Foundation & Setup (Week 1-2)

### Story 1.1: Environment Setup
**Goal**: Get your development environment ready
**Time Estimate**: 2-3 hours

**Tasks:**
- [ ] Install Xcode 14+ from App Store
- [ ] Create Apple Developer account (free is fine to start)
- [ ] Create new iOS project in Xcode
- [ ] Set up GitHub repository
- [ ] Learn basic Xcode navigation

**Learning Focus**: Xcode IDE, project structure, version control

**Acceptance Criteria:**
- ✅ Xcode project builds and runs in simulator
- ✅ GitHub repo created with initial commit
- ✅ Can navigate Xcode interface confidently

**Resources Needed:**
- Mac with macOS 12.0+
- Apple ID for developer account

---

### Story 1.2: Basic App Structure
**Goal**: Create the foundation SwiftUI app with tab navigation
**Time Estimate**: 3-4 hours

**Tasks:**
- [ ] Create main TabView with 4 tabs (Lists, Recipes, Staples, Settings)
- [ ] Add placeholder views for each tab
- [ ] Configure tab icons and labels
- [ ] Test navigation between tabs
- [ ] Commit changes to GitHub

**Learning Focus**: SwiftUI basics, navigation, project organization

**Code Files to Create:**
```
- ContentView.swift (main tab view)
- Views/GroceryListsView.swift (placeholder)
- Views/RecipesView.swift (placeholder)  
- Views/StaplesView.swift (placeholder)
- Views/SettingsView.swift (placeholder)
```

**Acceptance Criteria:**
- ✅ App shows 4 tabs with correct icons
- ✅ Tapping tabs navigates properly
- ✅ Each tab shows placeholder content
- ✅ App runs without crashes

---

## 📊 Phase 2: Core Data Foundation (Week 2-3)

### Story 2.1: Core Data Model Setup
**Goal**: Design and create the database structure
**Time Estimate**: 4-5 hours

**Tasks:**
- [ ] Open .xcdatamodeld file in Xcode
- [ ] Create GroceryItem entity with attributes
- [ ] Create Recipe entity with attributes
- [ ] Create RecipeIngredient entity
- [ ] Set up entity relationships
- [ ] Generate NSManagedObject subclasses

**Learning Focus**: Core Data concepts, entity relationships, data modeling

**Entities to Create:**
1. **GroceryItem** (id, name, category, isStaple, dateCreated, lastPurchased)
2. **Recipe** (id, name, instructions, servings, prepTime, cookTime, dateCreated, lastUsed, usageCount, tags, isFavorite)
3. **RecipeIngredient** (id, name, quantity, unit, notes)

**Acceptance Criteria:**
- ✅ All entities created with correct attributes
- ✅ Recipe ↔ RecipeIngredient relationship established
- ✅ Core Data model validates without errors
- ✅ NSManagedObject classes generated

---

### Story 2.2: Core Data Stack
**Goal**: Set up the persistence layer
**Time Estimate**: 2-3 hours

**Tasks:**
- [ ] Create PersistenceController class
- [ ] Configure Core Data stack
- [ ] Add preview data for development
- [ ] Inject managed context into app
- [ ] Test Core Data setup

**Learning Focus**: Core Data stack, dependency injection, preview data

**Files to Create/Modify:**
- PersistenceController.swift
- Update App.swift with Core Data environment

**Acceptance Criteria:**
- ✅ Core Data stack initializes properly
- ✅ Preview data loads in SwiftUI previews
- ✅ No Core Data startup errors
- ✅ Memory management working correctly

---

## 🥖 Phase 3: Staples Management (Week 3-4)

### Story 3.1: View Staples List
**Goal**: Display existing staple items
**Time Estimate**: 3-4 hours

**Tasks:**
- [ ] Create @FetchRequest for staples
- [ ] Build StaplesView with List
- [ ] Create StapleRowView component
- [ ] Add search functionality
- [ ] Group staples by category
- [ ] Test with sample data

**Learning Focus**: @FetchRequest, SwiftUI List, search implementation

**SwiftUI Concepts:**
- @FetchRequest for automatic Core Data integration
- List and ForEach for data display
- SearchBar implementation
- Sectioned lists

**Acceptance Criteria:**
- ✅ Staples display in categorized list
- ✅ Search filters results correctly
- ✅ Empty state shows appropriate message
- ✅ Smooth scrolling performance

---

### Story 3.2: Add New Staples
**Goal**: Create interface to add staple items
**Time Estimate**: 3-4 hours

**Tasks:**
- [ ] Create NewStapleView as sheet
- [ ] Add form for name and category
- [ ] Implement category picker/suggestions
- [ ] Add save functionality
- [ ] Handle form validation
- [ ] Test add/cancel flows

**Learning Focus**: Sheet presentation, forms, data validation

**SwiftUI Concepts:**
- Sheet presentation
- Form and TextField
- Data binding with @State
- Core Data object creation

**Acceptance Criteria:**
- ✅ Modal sheet presents correctly
- ✅ Form validation works
- ✅ New staples save to Core Data
- ✅ List updates automatically after save

---

### Story 3.3: Edit/Delete Staples
**Goal**: Manage existing staple items
**Time Estimate**: 2-3 hours

**Tasks:**
- [ ] Add swipe actions for delete
- [ ] Implement edit functionality
- [ ] Add toggle staple status
- [ ] Track last purchased date
- [ ] Test edge cases

**Learning Focus**: Swipe actions, data updates, user interactions

**Acceptance Criteria:**
- ✅ Swipe to delete works
- ✅ Can toggle staple status
- ✅ Edit changes persist
- ✅ UI updates reflect changes

---

## 📖 Phase 4: Basic Recipe Management (Week 4-5)

### Story 4.1: Recipe List View
**Goal**: Display and search recipes
**Time Estimate**: 4-5 hours

**Tasks:**
- [ ] Create RecipesView with @FetchRequest
- [ ] Build RecipeRowView component
- [ ] Add search and tag filtering
- [ ] Show recipe metadata (usage, time, etc.)
- [ ] Add favorites indicator
- [ ] Test with various data

**Learning Focus**: Complex list views, filtering, search

**Acceptance Criteria:**
- ✅ Recipes display with metadata
- ✅ Search works across name and tags
- ✅ Tag filtering functions correctly
- ✅ Favorites highlighted properly

---

### Story 4.2: Recipe Detail View
**Goal**: Show full recipe information
**Time Estimate**: 3-4 hours

**Tasks:**
- [ ] Create RecipeDetailView
- [ ] Display recipe info and ingredients
- [ ] Add favorite toggle
- [ ] Implement "Mark as Used" function
- [ ] Show usage statistics
- [ ] Navigation setup

**Learning Focus**: Navigation, data relationships, user interactions

**Acceptance Criteria:**
- ✅ All recipe data displays correctly
- ✅ Ingredients list properly formatted
- ✅ Usage tracking works
- ✅ Navigation flows smoothly

---

### Story 4.3: Add New Recipe
**Goal**: Create interface for recipe entry
**Time Estimate**: 5-6 hours

**Tasks:**
- [ ] Create NewRecipeView form
- [ ] Build dynamic ingredients list
- [ ] Add recipe metadata fields
- [ ] Implement tags input
- [ ] Add form validation
- [ ] Test complex scenarios

**Learning Focus**: Complex forms, dynamic content, data relationships

**Acceptance Criteria:**
- ✅ Can add multiple ingredients dynamically
- ✅ All recipe data saves correctly
- ✅ Form validation prevents errors
- ✅ Ingredients relationship created properly

---

## 📝 Phase 5: Grocery Lists (Week 5-6)

### Story 5.1: List Management
**Goal**: Create and manage grocery lists
**Time Estimate**: 4-5 hours

**Tasks:**
- [ ] Create GroceryList and GroceryListItem entities
- [ ] Build list creation interface
- [ ] Auto-populate with staples option
- [ ] Show list progress/completion
- [ ] Test list management

**Learning Focus**: Entity relationships, data aggregation

---

### Story 5.2: List Items Management
**Goal**: Add, edit, and check off list items
**Time Estimate**: 4-5 hours

**Tasks:**
- [ ] Build list detail view
- [ ] Implement check/uncheck functionality
- [ ] Add manual items
- [ ] Add items from recipes
- [ ] Track item sources

**Learning Focus**: Interactive lists, state management

---

## ☁️ Phase 6: CloudKit Integration (Week 6-8)

### Story 6.1: Basic CloudKit Setup
**Goal**: Enable cloud sync
**Time Estimate**: 6-8 hours

**Tasks:**
- [ ] Configure CloudKit capability
- [ ] Update Core Data model for CloudKit
- [ ] Test basic sync functionality
- [ ] Handle sync conflicts
- [ ] Test offline/online scenarios

**Learning Focus**: CloudKit basics, data sync

---

### Story 6.2: Sharing Implementation
**Goal**: Enable family sharing
**Time Estimate**: 8-10 hours

**Tasks:**
- [ ] Implement CloudKit sharing
- [ ] Create sharing UI
- [ ] Test invitation flow
- [ ] Handle share acceptance
- [ ] Test collaborative editing

**Learning Focus**: CloudKit sharing, collaboration

---

## 🚀 Phase 7: Polish & Deployment (Week 8-9)

### Story 7.1: UI/UX Polish
**Goal**: Improve app experience
**Time Estimate**: 4-6 hours

**Tasks:**
- [ ] Add app icons
- [ ] Improve visual design
- [ ] Add loading states
- [ ] Enhance error handling
- [ ] Accessibility improvements

---

### Story 7.2: App Store Preparation
**Goal**: Prepare for release
**Time Estimate**: 3-4 hours

**Tasks:**
- [ ] App Store metadata
- [ ] Screenshots
- [ ] Privacy policy
- [ ] TestFlight testing
- [ ] App Store submission

---

## 📋 Development Best Practices

### Daily Workflow:
1. **Start Small**: Complete one story/task at a time
2. **Test Frequently**: Run app after each significant change
3. **Commit Often**: Save progress to GitHub regularly
4. **Ask Questions**: Don't hesitate to ask for help with concepts

### Learning Resources:
- **Apple Documentation**: SwiftUI and Core Data guides
- **WWDC Videos**: Especially CloudKit and Core Data sessions
- **Stack Overflow**: For specific coding questions
- **GitHub Examples**: Look at other iOS projects

### When to Ask for Help:
- ✅ Stuck on a concept for more than 30 minutes
- ✅ Getting compiler errors you don't understand
- ✅ Want to understand "why" something works a certain way
- ✅ Need code review before moving to next story

---

This roadmap will take approximately 8-9 weeks working part-time. Each phase builds on the previous one, teaching you iOS development incrementally while building a real, useful app.

**Ready to start with Story 1.1: Environment Setup?**