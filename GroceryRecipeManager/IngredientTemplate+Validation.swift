//
//  IngredientTemplate+Validation.swift
//  GroceryRecipeManager
//
//  Created for M3.5 Phase 1 Task 3: Template Validation
//  Date: October 22, 2025
//
//  Purpose: Add Core Data validation rules to IngredientTemplate entity
//  Note: IngredientTemplate uses Class Definition codegen, so validation added via extension
//

import Foundation
import CoreData

extension IngredientTemplate {
    
    // MARK: - Validation Methods
    
    /// Validates template data before insert
    /// Called automatically by Core Data when new template is inserted
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateTemplateData()
    }
    
    /// Validates template data before update
    /// Called automatically by Core Data when template is updated
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateTemplateData()
    }
    
    /// Core validation logic for template data
    internal func validateTemplateData() throws {
        // Validate name
        try validateName()
        
        // Validate category
        try validateCategory()
        
        // Validate usage count
        try validateUsageCount()
        
        // Validate date created
        try validateDateCreated()
    }
    
    // MARK: - Individual Field Validation
    
    private func validateName() throws {
        guard let name = self.name else {
            throw ValidationError.nameRequired
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            throw ValidationError.nameEmpty
        }
        
        if trimmedName.count < 2 {
            throw ValidationError.nameTooShort
        }
        
        if trimmedName.count > 100 {
            throw ValidationError.nameTooLong
        }
        
        // Check for duplicate names (case-insensitive)
        if let context = self.managedObjectContext {
            let fetchRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name ==[c] %@ AND self != %@", trimmedName, self)
            fetchRequest.fetchLimit = 1
            
            do {
                let duplicates = try context.fetch(fetchRequest)
                if !duplicates.isEmpty {
                    throw ValidationError.duplicateName(trimmedName)
                }
            } catch let error as ValidationError {
                throw error
            } catch {
                // Log but don't fail on fetch errors
                print("⚠️ Warning: Could not check for duplicate template names: \(error)")
            }
        }
    }
    
    private func validateCategory() throws {
        // Category is optional, but if provided, must be valid
        if let category = self.category {
            let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedCategory.isEmpty {
                // Empty string not allowed - should be nil instead
                throw ValidationError.categoryEmpty
            }
            
            if trimmedCategory.count > 50 {
                throw ValidationError.categoryTooLong
            }
        }
        // nil category is valid (uncategorized)
    }
    
    private func validateUsageCount() throws {
        if self.usageCount < 0 {
            throw ValidationError.negativeUsageCount
        }
        
        // Sanity check: usage count shouldn't be unreasonably high
        if self.usageCount > 10000 {
            throw ValidationError.usageCountTooHigh
        }
    }
    
    private func validateDateCreated() throws {
        guard let dateCreated = self.dateCreated else {
            throw ValidationError.dateCreatedRequired
        }
        
        // Date should not be in the future
        if dateCreated > Date() {
            throw ValidationError.dateCreatedInFuture
        }
        
        // Date should not be unreasonably old (before 2020)
        let oldestAllowedDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        if dateCreated < oldestAllowedDate {
            throw ValidationError.dateCreatedTooOld
        }
    }
    
    // MARK: - Computed Properties for Common Queries
    
    /// Returns true if template has a category assigned
    var hasCategory: Bool {
        return category != nil && !(category?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false)
    }
    
    /// Returns true if template is marked as a staple
    var isStapleItem: Bool {
        return isStaple
    }
    
    /// Returns true if template has been used at least once
    var hasBeenUsed: Bool {
        return usageCount > 0
    }
    
    /// Returns true if template is frequently used (10+ uses)
    var isFrequentlyUsed: Bool {
        return usageCount >= 10
    }
    
    /// Returns display name with proper formatting
    var displayName: String {
        return name ?? "Unknown Ingredient"
    }
    
    /// Returns category display name with proper formatting
    var displayCategory: String {
        return category ?? "Uncategorized"
    }
    
    /// Returns formatted usage description
    var usageDescription: String {
        switch usageCount {
        case 0:
            return "Never used"
        case 1:
            return "Used once"
        case 2...9:
            return "Used \(usageCount) times"
        case 10...49:
            return "Used often (\(usageCount))"
        default:
            return "Frequently used (\(usageCount))"
        }
    }
    
    /// Returns true if template has valid data for all required fields
    var isValid: Bool {
        do {
            try validateTemplateData()
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Validation Error Types
    
    enum ValidationError: LocalizedError {
        case nameRequired
        case nameEmpty
        case nameTooShort
        case nameTooLong
        case duplicateName(String)
        case categoryEmpty
        case categoryTooLong
        case negativeUsageCount
        case usageCountTooHigh
        case dateCreatedRequired
        case dateCreatedInFuture
        case dateCreatedTooOld
        
        var errorDescription: String? {
            switch self {
            case .nameRequired:
                return "Ingredient template name is required"
            case .nameEmpty:
                return "Ingredient template name cannot be empty"
            case .nameTooShort:
                return "Ingredient template name must be at least 2 characters"
            case .nameTooLong:
                return "Ingredient template name cannot exceed 100 characters"
            case .duplicateName(let name):
                return "An ingredient template named '\(name)' already exists"
            case .categoryEmpty:
                return "Category cannot be an empty string (use nil for uncategorized)"
            case .categoryTooLong:
                return "Category name cannot exceed 50 characters"
            case .negativeUsageCount:
                return "Usage count cannot be negative"
            case .usageCountTooHigh:
                return "Usage count exceeds reasonable limit (10,000)"
            case .dateCreatedRequired:
                return "Date created is required"
            case .dateCreatedInFuture:
                return "Date created cannot be in the future"
            case .dateCreatedTooOld:
                return "Date created cannot be before 2020"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .nameRequired, .nameEmpty:
                return "Provide a valid ingredient name"
            case .nameTooShort:
                return "Use a longer, more descriptive name"
            case .nameTooLong:
                return "Shorten the ingredient name to 100 characters or less"
            case .duplicateName:
                return "Use the existing template or choose a different name"
            case .categoryEmpty:
                return "Set category to nil or provide a valid category name"
            case .categoryTooLong:
                return "Shorten the category name"
            case .negativeUsageCount:
                return "Reset usage count to 0 or a positive number"
            case .usageCountTooHigh:
                return "Verify the usage count is correct"
            case .dateCreatedRequired:
                return "Set date created to current date"
            case .dateCreatedInFuture:
                return "Set date created to current date or earlier"
            case .dateCreatedTooOld:
                return "Verify the date created is correct"
            }
        }
    }
}

// MARK: - Debug Description

extension IngredientTemplate {
    /// Returns detailed debug description of template
    public override var debugDescription: String {
        return """
        IngredientTemplate {
            id: \(id?.uuidString ?? "nil")
            name: \(name ?? "nil")
            category: \(category ?? "nil")
            isStaple: \(isStaple)
            usageCount: \(usageCount)
            dateCreated: \(dateCreated?.description ?? "nil")
            isValid: \(isValid)
        }
        """
    }
}
