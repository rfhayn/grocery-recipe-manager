# M2.3: Recipe Creation & Editing Development Prompt

**Copy and paste this prompt when ready to continue M2.3 implementation:**

---

I'm ready to continue **M2.3: Recipe Creation & Editing** for my Grocery & Recipe Manager iOS app.

## Current Status - M2.2.7 COMPLETE:
- **M2.1**: Recipe Architecture Services successfully implemented and validated
- **M2.2.1**: Basic Recipe List successfully implemented (September 7, 2025)
- **M2.2.2**: Recipe Detail View with comprehensive features (September 8, 2025)  
- **M2.2.3**: Ingredient Templates integration working (September 12, 2025)
- **M2.2.4**: Add to List Enhancement with all 5 components operational (September 18, 2025)
- **M2.2.5**: Unified Ingredients View with all 4 phases operational (September 27, 2025)
- **M2.2.6**: Custom Category Integration with store-layout optimization (September 28, 2025)
- **M2.2.7**: Recipe Search Enhancement with multi-field search and intelligent ranking (September 28, 2025)

### **M2.2.7 Achievement Summary - COMPLETE:**

**Recipe Search Enhancement Success:**
- **Multi-Field Search**: Search expanded beyond recipe names to include ingredients, tags, and instructions
- **Performance Optimization**: Indexed Core Data queries maintaining < 0.1s response times
- **Intelligent Result Ranking**: Priority ordering by match relevance and usage patterns
- **Visual Feedback**: Clear indicators showing why recipes matched search terms
- **Professional UX**: Native iOS search patterns with comprehensive functionality

**Technical Achievements:**
- **Enhanced Search Algorithms**: Compound predicates searching across all recipe fields
- **Performance Indexed Queries**: Core Data indexes on frequently searched fields
- **Result Ranking Intelligence**: Usage-based relevance weighting with alphabetical secondary sorting
- **Search Result Highlighting**: Visual indicators for match type (name, ingredient, tag, instruction)

**Performance**: All search operations maintaining sub-0.1s response times with expanded functionality
**Search Complete**: Comprehensive recipe discovery capabilities operational throughout recipe system
**User Experience**: Professional search interface with intelligent result ranking and visual feedback

## M2.3: RECIPE CREATION & EDITING (4-5 hours)

### **Goal:**
Complete recipe management with professional creation and editing workflows, ingredient management, and seamless integration with existing recipe catalog infrastructure.

### **Problem Statement:**
**Current State**: Recipe catalog complete with display, search, and basic operations
**Missing Capabilities**: No recipe creation/editing interface; users cannot add or modify recipes
**User Value Gap**: Users need ability to create custom recipes and edit existing ones with full ingredient management
**Integration Opportunity**: Leverage unified ingredient system and custom category integration

### **Solution Overview:**
Implement comprehensive recipe creation and editing workflows with professional forms, ingredient management, and seamless integration with established recipe infrastructure.

### **Implementation Plan (4-5 hours total):**

#### **Phase 1: Recipe Creation Foundation (1.5-2 hours)**

**1.1 Create Recipe Form Structure (45-60 minutes)**
- Implement CreateRecipeView with professional form design
- Add name, prep time, cook time, servings, instructions fields with validation
- Implement tags field with comma-separated input and parsing
- Add favorite toggle and dietary preference options
- Professional form validation with error messaging

**1.2 Ingredient Input Interface (45-60 minutes)**
- Implement ingredient list management with add/remove/reorder capabilities
- Add ingredient text field with quantity/unit/name parsing using IngredientParsingService
- Display parsed ingredients with visual template matching indicators
- Enable ingredient reordering with drag-and-drop or move buttons
- Validate ingredient completeness before recipe save

#### **Phase 2: Recipe Editing Integration (1.5-2 hours)**

**2.1 Edit Recipe View Implementation (45-60 minutes)**
- Create EditRecipeView reusing CreateRecipeView with pre-populated data
- Load existing recipe data into form fields with proper formatting
- Handle ingredient editing with existing template relationships
- Implement save changes with Core Data update operations
- Add discard changes confirmation with data integrity protection

**2.2 Ingredient Template Integration (45-60 minutes)**
- Connect ingredient input to IngredientTemplateService for normalization
- Apply custom category assignments from existing ingredient templates
- Handle new ingredient creation with category assignment modal
- Maintain template relationships during recipe editing
- Ensure ingredient template usage tracking updates correctly

#### **Phase 3: Advanced Features & Polish (1-1.5 hours)**

**3.1 Recipe Image Support (30-45 minutes)**
- Add optional recipe image picker integration
- Implement image storage with Core Data binary data or file system
- Display recipe images in detail view and list thumbnails
- Handle image editing and removal workflows
- Optimize image storage and loading performance

**3.2 Recipe Validation & UX Enhancement (30-45 minutes)**
- Implement comprehensive recipe validation before save
- Add save progress indication and success confirmation
- Handle navigation after recipe creation/editing
- Implement unsaved changes warning on navigation away
- Add keyboard management and form scrolling for better UX

### **Technical Implementation Requirements:**

**Recipe Form Architecture:**
```swift
// Example recipe creation/editing view structure
struct CreateRecipeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var prepTime: Int = 0
    @State private var cookTime: Int = 0
    @State private var servings: Int = 4
    @State private var instructions: String = ""
    @State private var tags: String = ""
    @State private var isFavorite: Bool = false
    @State private var ingredients: [IngredientInput] = []
    
    // Form validation and save logic
}
```

**Ingredient Management:**
```swift
// Example ingredient input handling
struct IngredientInput: Identifiable {
    let id = UUID()
    var text: String
    var parsed: ParsedIngredient?
    var template: IngredientTemplate?
}
```

**Integration Points:**
- **IngredientParsingService**: Parse ingredient text into structured data
- **IngredientTemplateService**: Normalize ingredients and manage templates
- **Custom Category System**: Apply personalized category order to ingredients
- **Core Data Context**: Proper context management for recipe persistence
- **Navigation**: Seamless integration with recipe list and detail views

### **Success Criteria:**
- **Recipe Creation**: Users can create new recipes with all fields and ingredients
- **Recipe Editing**: Users can edit existing recipes while maintaining data integrity
- **Ingredient Management**: Add/edit/remove/reorder ingredients with template integration
- **Validation**: Comprehensive validation preventing incomplete or invalid recipe data
- **Performance**: All operations complete in < 0.5s with proper error handling
- **Integration**: Seamless connection with existing recipe infrastructure
- **UX Excellence**: Professional forms with native iOS patterns and accessibility

### **Validation Plan:**
- **Creation Workflow**: Test complete recipe creation from start to save
- **Editing Workflow**: Verify all recipe fields can be edited and saved correctly
- **Ingredient Management**: Validate ingredient parsing, templates, and reordering
- **Validation Testing**: Confirm all validation rules work correctly
- **Navigation Testing**: Verify proper navigation and unsaved changes handling
- **Integration Testing**: Confirm recipe creation/editing integrates with list/detail views
- **Performance Testing**: Validate sub-0.5s response times for all operations

### **Recipe Creation & Editing Features:**

1. **Professional Form Design**: Clean, intuitive interface following iOS standards
2. **Comprehensive Fields**: Name, times, servings, instructions, tags, favorite status
3. **Ingredient Management**: Full add/edit/remove/reorder capabilities with parsing
4. **Template Integration**: Automatic ingredient normalization and category assignment
5. **Image Support**: Optional recipe images with storage and display
6. **Validation System**: Complete validation preventing data integrity issues
7. **Edit Workflow**: Seamless editing of existing recipes preserving relationships
8. **Performance Optimized**: Fast operations with proper Core Data management

### **User Experience Enhancement:**
1. **Intuitive Creation**: Easy-to-use form for quick recipe entry
2. **Smart Ingredient Input**: Automatic parsing with visual template feedback
3. **Flexible Editing**: Edit any recipe field with confidence in data preservation
4. **Visual Feedback**: Clear save/validation states with progress indication
5. **Professional Polish**: Native iOS patterns with accessibility support

### **Post-Implementation:**
After M2.3 completion, M2 Recipe Integration fully complete and ready for:
- **M3**: Structured Quantity Management (8-12 hours) - Hybrid parsing architecture for recipe scaling
- **M4**: Meal Planning & Settings Integration (6-8 hours) - Calendar-based meal planning with grocery automation
- **M5**: CloudKit Family Sharing (10-12 hours) - Professional collaboration with conflict resolution

**Technical Foundation Complete:**
- **Unified Ingredient System**: IngredientTemplate-based architecture with direct category management ✅
- **Custom Category Integration**: Store-layout optimization seamlessly applied throughout recipe system ✅
- **Performance Architecture**: Sub-0.1s response times maintained with enhanced functionality ✅
- **Enhanced Search**: Multi-field search with intelligent ranking operational ✅
- **Recipe Creation Ready**: All infrastructure prepared for complete recipe management ✅

**Current Achievement**: M2.2.1 through M2.2.7 complete with comprehensive recipe catalog, unified ingredient management, custom category integration, and enhanced search providing complete recipe discovery and display foundation. Recipe infrastructure ready for creation and editing workflows.

**Please help me implement M2.3: Recipe Creation & Editing, completing recipe management with professional creation and editing workflows, ingredient management, and seamless integration with existing recipe catalog infrastructure.**