//
//  IngredientParsingService.swift
//  GroceryRecipeManager
//
//  Created on September 12, 2025
//  MILESTONE 2 - Phase 2: Recipe Core Development
//  Step 3: IngredientTemplate Integration
//

import Foundation
import CoreData

struct ParsedIngredient {
    let originalText: String
    let quantity: String?
    let unit: String?
    let name: String
    let notes: String?
    
    var displayName: String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isFullyParsed: Bool {
        return quantity != nil && unit != nil && !name.isEmpty
    }
}

/// Service for intelligent ingredient text parsing and IngredientTemplate integration
class IngredientParsingService: ObservableObject {
    private let context: NSManagedObjectContext
    private let templateService: IngredientTemplateService
    
    // Performance tracking
    @Published var lastParsingDuration: TimeInterval = 0
    @Published var parseSuccessRate: Double = 0.0
    
    init(context: NSManagedObjectContext, templateService: IngredientTemplateService) {
        self.context = context
        self.templateService = templateService
    }
    
    // MARK: - Smart Ingredient Parsing
    
    /// Parse ingredient text into structured components
    func parseIngredient(text: String) -> ParsedIngredient {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle empty or very short text
        guard !trimmedText.isEmpty else {
            return ParsedIngredient(
                originalText: text,
                quantity: nil,
                unit: nil,
                name: "Unknown ingredient",
                notes: nil
            )
        }
        
        if trimmedText.count < 3 {
            return ParsedIngredient(
                originalText: text,
                quantity: nil,
                unit: nil,
                name: trimmedText,
                notes: nil
            )
        }
        
        // Parse using regex patterns for common ingredient formats
        let parsed = parseWithPatterns(text: trimmedText)
        
        // Track performance
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        self.lastParsingDuration = duration
        
        return parsed
    }
    
    /// Parse ingredient list and connect to templates
    func parseAndConnectIngredients(for recipe: Recipe, ingredientTexts: [String]) -> [Ingredient] {
        var createdIngredients: [Ingredient] = []
        var successfulParses = 0
        
        for (index, text) in ingredientTexts.enumerated() {
            let parsedIngredient = parseIngredient(text: text)
            
            // Create Ingredient entity
            let ingredient = Ingredient(context: context)
            ingredient.id = UUID()
            ingredient.name = parsedIngredient.originalText // Store original text as name
            ingredient.quantity = parsedIngredient.quantity
            ingredient.unit = parsedIngredient.unit
            ingredient.notes = parsedIngredient.notes
            ingredient.sortOrder = Int16(index)
            ingredient.recipe = recipe
            
            // Connect to IngredientTemplate for normalization
            let template = templateService.findOrCreateTemplate(
                name: parsedIngredient.displayName,
                category: categorizeIngredient(parsedIngredient.displayName)
            )
            ingredient.ingredientTemplate = template
            templateService.incrementUsage(template: template)
            
            createdIngredients.append(ingredient)
            
            if parsedIngredient.isFullyParsed {
                successfulParses += 1
            }
        }
        
        // Update success rate
        if !ingredientTexts.isEmpty {
            parseSuccessRate = Double(successfulParses) / Double(ingredientTexts.count)
        }
        
        return createdIngredients
    }
    
    // MARK: - Pattern-Based Parsing
    
    private func parseWithPatterns(text: String) -> ParsedIngredient {
        // Pattern 1: "2 cups flour" or "1 1/2 tbsp olive oil"
        let pattern1 = #"^([0-9]+(?:\s+[0-9]+/[0-9]+|[/.][0-9]+)?)\s+([a-zA-Z]+)?\s*(.+)$"#
        if let match = matchPattern(pattern1, in: text) {
            let quantity = match[1]
            let unit = match[2].isEmpty ? nil : match[2]
            let name = match[3].trimmingCharacters(in: .whitespacesAndNewlines)
            
            return ParsedIngredient(
                originalText: text,
                quantity: quantity,
                unit: unit,
                name: name,
                notes: nil
            )
        }
        
        // Pattern 2: "Salt to taste" or "Pepper as needed"
        let pattern2 = #"^([a-zA-Z\s]+?)\s+(to taste|as needed|as desired)$"#
        if let match = matchPattern(pattern2, in: text) {
            let name = match[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let notes = match[2]
            
            return ParsedIngredient(
                originalText: text,
                quantity: nil,
                unit: nil,
                name: name,
                notes: notes
            )
        }
        
        // Pattern 3: "A pinch of salt" or "A handful of nuts"
        let pattern3 = #"^(a\s+(?:pinch|dash|handful))\s+of\s+(.+)$"#
        if let match = matchPattern(pattern3, in: text) {
            let quantity = match[1]
            let name = match[2].trimmingCharacters(in: .whitespacesAndNewlines)
            
            return ParsedIngredient(
                originalText: text,
                quantity: quantity,
                unit: nil,
                name: name,
                notes: nil
            )
        }
        
        // Pattern 4: Just ingredient name
        return ParsedIngredient(
            originalText: text,
            quantity: nil,
            unit: nil,
            name: text,
            notes: nil
        )
    }
    
    private func matchPattern(_ pattern: String, in text: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else {
            return nil
        }
        
        var results: [String] = []
        for i in 0..<match.numberOfRanges {
            let matchRange = match.range(at: i)
            if matchRange.location != NSNotFound,
               let range = Range(matchRange, in: text) {
                results.append(String(text[range]))
            } else {
                results.append("")
            }
        }
        
        return results.isEmpty ? nil : results
    }
    
    // MARK: - Category Assignment
    
    private func categorizeIngredient(_ name: String) -> String {
        let lowercaseName = name.lowercased()
        
        // Basic categorization logic (can be enhanced with your custom category system)
        if lowercaseName.contains("milk") || lowercaseName.contains("cheese") ||
           lowercaseName.contains("butter") || lowercaseName.contains("yogurt") {
            return "Dairy"
        } else if lowercaseName.contains("chicken") || lowercaseName.contains("beef") ||
                  lowercaseName.contains("pork") || lowercaseName.contains("fish") {
            return "Meat & Seafood"
        } else if lowercaseName.contains("apple") || lowercaseName.contains("banana") ||
                  lowercaseName.contains("orange") || lowercaseName.contains("berry") {
            return "Produce"
        } else if lowercaseName.contains("flour") || lowercaseName.contains("bread") ||
                  lowercaseName.contains("rice") || lowercaseName.contains("pasta") {
            return "Pantry"
        } else if lowercaseName.contains("salt") || lowercaseName.contains("pepper") ||
                  lowercaseName.contains("spice") || lowercaseName.contains("herb") {
            return "Seasonings"
        } else {
            return "Other"
        }
    }
    
    // MARK: - Template Matching
    
    /// Find matching templates for autocomplete
    func findMatchingTemplates(for name: String, limit: Int = 5) -> [IngredientTemplate] {
        return templateService.searchTemplates(query: name, limit: limit)
    }
    
    /// Validate parsing performance
    func validateParsingPerformance() -> Bool {
        // Test parsing with sample ingredient
        let _ = parseIngredient(text: "2 cups all-purpose flour")
        return lastParsingDuration < 0.05 // Target: < 0.05s for parsing
    }
}
