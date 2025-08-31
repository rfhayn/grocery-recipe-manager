//
//  IngredientTemplateService.swift
//  GroceryRecipeManager
//
//  Phase 0 Step 3: Corrected to match actual Core Data model
//  Using IngredientTemplate entity with: id, name, category, dateCreated, usageCount
//

import Foundation
import CoreData
import SwiftUI

/// Advanced ingredient template service for data normalization and autocomplete
/// Implementation using actual IngredientTemplate entity structure
class IngredientTemplateService: ObservableObject {
    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    // MARK: - Published Properties for SwiftUI Integration
    @Published private(set) var popularIngredients: [IngredientTemplate] = []
    @Published private(set) var autocompleteResults: [IngredientTemplate] = []
    
    // Performance tracking
    @Published private(set) var lastSearchDuration: TimeInterval = 0.0
    
    // MARK: - Internal Caching for Performance
    private var ingredientCache: [String: IngredientTemplate] = [:]
    private let cacheQueue = DispatchQueue(label: "ingredient.template.cache", qos: .userInitiated)
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.parent = context
        
        // Initialize caches on startup
        Task {
            await loadInitialCache()
        }
    }
    
    // MARK: - Template Normalization Core
    
    /// Finds or creates an IngredientTemplate, preventing duplication
    /// Core normalization method ensuring data consistency across app
    func findOrCreateTemplate(name: String, category: String? = nil, defaultUnit: String? = nil) async throws -> IngredientTemplate {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<IngredientTemplate, Error>) in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Context deallocated"]))
                    return
                }
                
                do {
                    let normalizedName = self.normalizeIngredientName(name)
                    
                    // First check cache for performance
                    if let cached = self.ingredientCache[normalizedName] {
                        self.updateUsageCount(template: cached)
                        continuation.resume(returning: cached)
                        return
                    }
                    
                    // Optimized database search using performance index
                    let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                    request.predicate = NSPredicate(format: "name ==[cd] %@", normalizedName)
                    request.fetchLimit = 1
                    request.returnsObjectsAsFaults = false
                    
                    let existingTemplates = try self.backgroundContext.fetch(request)
                    
                    let template: IngredientTemplate
                    
                    if let existing = existingTemplates.first {
                        // Update existing template
                        template = existing
                        
                        // Smart category assignment - prefer more specific categories
                        if let newCategory = category, !newCategory.isEmpty {
                            if existing.category?.isEmpty ?? true || self.isMoreSpecificCategory(newCategory, than: existing.category) {
                                existing.category = newCategory
                            }
                        }
                        
                        self.updateUsageCount(template: existing)
                        
                    } else {
                        // Create new template with intelligent defaults
                        template = IngredientTemplate(context: self.backgroundContext)
                        template.id = UUID()
                        template.name = normalizedName
                        template.category = category ?? self.inferCategory(from: normalizedName)
                        template.dateCreated = Date()
                        template.usageCount = 1
                    }
                    
                    try self.backgroundContext.save()
                    
                    // Update cache for future performance
                    self.cacheQueue.async {
                        self.ingredientCache[normalizedName] = template
                    }
                    
                    continuation.resume(returning: template)
                    
                } catch {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to find/create ingredient template: \(error.localizedDescription)"]))
                }
            }
        }
    }
    
    // MARK: - Intelligent Autocomplete System
    
    /// Provides real-time autocomplete suggestions with fuzzy matching
    /// Optimized for sub-50ms response times during typing
    func searchTemplates(query: String, limit: Int = 10) async throws -> [IngredientTemplate] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[IngredientTemplate], Error>) in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Context deallocated"]))
                    return
                }
                
                do {
                    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    
                    if normalizedQuery.isEmpty {
                        // Return popular ingredients for empty query
                        continuation.resume(returning: Array(self.popularIngredients.prefix(limit)))
                        return
                    }
                    
                    let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                    
                    // Advanced search using performance index
                    let exactMatch = NSPredicate(format: "name BEGINSWITH[cd] %@", normalizedQuery)
                    let containsMatch = NSPredicate(format: "name CONTAINS[cd] %@", normalizedQuery)
                    let categoryMatch = NSPredicate(format: "category CONTAINS[cd] %@", normalizedQuery)
                    
                    // Compound predicate for comprehensive matching
                    request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                        exactMatch, containsMatch, categoryMatch
                    ])
                    
                    // Performance-optimized sorting using index
                    request.sortDescriptors = [
                        NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
                        NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
                    ]
                    
                    request.fetchLimit = limit
                    request.returnsObjectsAsFaults = false
                    
                    let templates = try self.backgroundContext.fetch(request)
                    
                    let searchDuration = CFAbsoluteTimeGetCurrent() - startTime
                    
                    DispatchQueue.main.async {
                        self.lastSearchDuration = searchDuration
                        self.autocompleteResults = templates
                    }
                    
                    if searchDuration > 0.05 {
                        print("⚠️ SEARCH PERFORMANCE: Template search took \(String(format: "%.3f", searchDuration))s")
                    }
                    
                    continuation.resume(returning: templates)
                    
                } catch {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to search templates: \(error.localizedDescription)"]))
                }
            }
        }
    }
    
    /// Loads most popular ingredients based on usage analytics
    func loadPopularIngredients(limit: Int = 20) async throws {
        let templates = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[IngredientTemplate], Error>) in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Context deallocated"]))
                    return
                }
                
                do {
                    let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                    request.sortDescriptors = [
                        NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
                        NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
                    ]
                    request.fetchLimit = limit
                    request.returnsObjectsAsFaults = false
                    
                    let templates = try self.backgroundContext.fetch(request)
                    continuation.resume(returning: templates)
                    
                } catch {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to load popular ingredients: \(error.localizedDescription)"]))
                }
            }
        }
        
        DispatchQueue.main.async {
            self.popularIngredients = templates
        }
    }
    
    // MARK: - Analytics & Insights
    
    /// Provides analytics data for ingredient usage patterns
    func getIngredientAnalytics() async throws -> (totalTemplates: Int, categoryCounts: [String: Int], topIngredients: [(String, Int32)]) {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(totalTemplates: Int, categoryCounts: [String: Int], topIngredients: [(String, Int32)]), Error>) in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Context deallocated"]))
                    return
                }
                
                do {
                    // Total templates count
                    let totalRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                    let totalCount = try self.backgroundContext.count(for: totalRequest)
                    
                    // Category distribution
                    var categoryCounts: [String: Int] = [:]
                    let categories = ["Produce", "Meat & Seafood", "Dairy", "Pantry", "Frozen", "Other"]
                    
                    for category in categories {
                        let categoryRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                        categoryRequest.predicate = NSPredicate(format: "category == %@", category)
                        categoryCounts[category] = try self.backgroundContext.count(for: categoryRequest)
                    }
                    
                    // Top ingredients by usage
                    let topRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                    topRequest.sortDescriptors = [NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false)]
                    topRequest.fetchLimit = 10
                    
                    let topTemplates = try self.backgroundContext.fetch(topRequest)
                    let topIngredients = topTemplates.map { ($0.name ?? "Unknown", $0.usageCount) }
                    
                    continuation.resume(returning: (totalCount, categoryCounts, topIngredients))
                    
                } catch {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get ingredient analytics: \(error.localizedDescription)"]))
                }
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func loadInitialCache() async {
        do {
            try await loadPopularIngredients()
        } catch {
            print("Warning: Failed to load initial ingredient cache: \(error)")
        }
    }
    
    private func normalizeIngredientName(_ name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .capitalized
    }
    
    private func updateUsageCount(template: IngredientTemplate) {
        template.usageCount += 1
        
        // Update cache asynchronously
        cacheQueue.async { [weak self] in
            self?.ingredientCache[template.name ?? ""] = template
        }
    }
    
    private func inferCategory(from ingredientName: String) -> String {
        let name = ingredientName.lowercased()
        
        // Produce
        let produceKeywords = ["apple", "banana", "orange", "lettuce", "spinach", "carrot", "onion", "tomato", "potato", "pepper", "cucumber", "broccoli", "celery", "mushroom", "garlic", "lemon", "lime", "avocado"]
        if produceKeywords.contains(where: name.contains) {
            return "Produce"
        }
        
        // Meat & Seafood
        let meatKeywords = ["chicken", "beef", "pork", "turkey", "fish", "salmon", "tuna", "shrimp", "bacon", "ham", "sausage", "ground", "steak"]
        if meatKeywords.contains(where: name.contains) {
            return "Meat & Seafood"
        }
        
        // Dairy
        let dairyKeywords = ["milk", "cheese", "yogurt", "butter", "cream", "egg", "sour cream"]
        if dairyKeywords.contains(where: name.contains) {
            return "Dairy"
        }
        
        // Pantry/Dry Goods
        let pantryKeywords = ["flour", "sugar", "rice", "pasta", "oil", "vinegar", "salt", "pepper", "spice", "bean", "lentil", "quinoa", "oat"]
        if pantryKeywords.contains(where: name.contains) {
            return "Pantry"
        }
        
        // Frozen
        let frozenKeywords = ["frozen", "ice cream", "popsicle"]
        if frozenKeywords.contains(where: name.contains) {
            return "Frozen"
        }
        
        // Default category
        return "Other"
    }
    
    private func isMoreSpecificCategory(_ newCategory: String, than existingCategory: String?) -> Bool {
        guard let existing = existingCategory else { return true }
        
        // Define category specificity hierarchy
        let categorySpecificity = [
            "Other": 0,
            "Pantry": 1,
            "Produce": 2,
            "Dairy": 2,
            "Meat & Seafood": 2,
            "Frozen": 1,
            "Beverages": 1
        ]
        
        let newSpecificity = categorySpecificity[newCategory] ?? 0
        let existingSpecificity = categorySpecificity[existing] ?? 0
        
        return newSpecificity > existingSpecificity
    }
}
