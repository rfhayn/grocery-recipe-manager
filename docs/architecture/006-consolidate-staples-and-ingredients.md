# Architecture Decision Record: Step 4 IngredientsView Consolidation

**ADR Number**: 006
**Date**: September 27, 2025  
**Status**: Implemented  
**Context**: Milestone 2 Phase 2 Step 4 - IngredientsView Consolidation  

---

## Decision Summary

Consolidate fragmented ingredient management into a unified IngredientTemplate-based system, replacing StaplesView with comprehensive IngredientsView that provides direct category assignment and eliminates workflow dependencies.

## Context

After completing Steps 1-3a of Recipe Core Development, the application had evolved into a dual ingredient management system:
- **Recipe ingredients** managed through IngredientTemplate entities with category relationships
- **Staple items** managed through GroceryItem.isStaple with separate workflow patterns
- **Category assignment** only available through recipe flows or category deletion workflows

This fragmentation created data inconsistency, user workflow friction, and limited visibility into comprehensive ingredient management.

### Key Requirements
- Unify all ingredient data under single IngredientTemplate system
- Provide direct category assignment without workflow dependencies
- Preserve all existing staple data during migration
- Maintain < 0.1s response times with enhanced functionality
- Enable comprehensive ingredient visibility and management

### Constraints
- Must preserve all existing user data during consolidation
- Cannot break existing recipe functionality from Steps 1-3a
- Must maintain professional UI standards established in Milestone 1
- Limited to 3-4 hour implementation window

## Decision

### Implemented Unified Architecture

#### **Phase 1: Core Data Model Consolidation (45 minutes)**
**Approach**: Add IngredientTemplate.isStaple property and migrate existing staple data

**Implementation Details**:
```swift
// Core Data model enhancement
@NSManaged public var isStaple: Bool

// Migration strategy
extension IngredientTemplate {
    static func migrateStaplesFromGroceryItems(in context: NSManagedObjectContext) {
        // Preserve all existing staple data with category assignments
        // Handle duplicate ingredient names with conflict resolution
        // Validate migration success with data integrity checks
    }
}
```

**Migration Benefits**:
- Zero data loss during system consolidation
- Category assignments preserved through migration process
- Single entity managing all ingredient-related data