import Foundation
import CoreData

/// Service for IngredientTemplate normalization and autocomplete functionality
/// Prevents ingredient duplication across recipes and staples
class IngredientTemplateService: ObservableObject {
    private let context: NSManagedObjectContext
    
    // Performance tracking
    @Published var lastSearchDuration: TimeInterval = 0
    @Published var popularIngredients: [IngredientTemplate] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Template Search and Autocomplete
    
    /// Search ingredient templates for autocomplete functionality
    func searchTemplates(query: String, limit: Int = 10) -> [IngredientTemplate] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        
        // Search by name (case-insensitive)
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        }
        
        // Sort by usage count (most used first), then name
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ]
        
        request.fetchLimit = limit
        
        do {
            let templates = try context.fetch(request)
            
            // Track performance
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            self.lastSearchDuration = duration
            
            return templates
        } catch {
            print("Error searching ingredient templates: \(error)")
            return []
        }
    }
    
    // MARK: - Popular Ingredients
    
    /// Load most popular ingredient templates
    func loadPopularIngredients(limit: Int = 20) -> [IngredientTemplate] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        
        // Get most used templates
        request.predicate = NSPredicate(format: "usageCount > 0")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ]
        request.fetchLimit = limit
        
        do {
            let templates = try context.fetch(request)
            
            // Track performance and update published property
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            self.lastSearchDuration = duration
            self.popularIngredients = templates
            
            return templates
        } catch {
            print("Error loading popular ingredients: \(error)")
            return []
        }
    }
    
    // MARK: - Template Management
    
    /// Find or create ingredient template
    func findOrCreateTemplate(name: String, category: String? = nil) -> IngredientTemplate {
        // First, try to find existing template
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", name)
        
        do {
            if let existingTemplate = try context.fetch(request).first {
                return existingTemplate
            }
        } catch {
            print("Error searching for existing template: \(error)")
        }
        
        // Create new template if not found
        let newTemplate = IngredientTemplate(context: context)
        newTemplate.id = UUID()
        newTemplate.name = name
        newTemplate.category = category
        newTemplate.usageCount = 1
        newTemplate.dateCreated = Date()
        
        do {
            try context.save()
        } catch {
            print("Error saving new ingredient template: \(error)")
        }
        
        return newTemplate
    }
    
    // MARK: - Usage Tracking
    
    /// Increment usage count for template
    func incrementUsage(template: IngredientTemplate) {
        template.usageCount += 1
        
        do {
            try context.save()
        } catch {
            print("Error updating template usage: \(error)")
        }
    }
    
    // MARK: - Performance Validation
    
    /// Validate template search performance
    func validateSearchPerformance() -> Bool {
        // Test search with common query
        let _ = searchTemplates(query: "a", limit: 5)
        return lastSearchDuration < 0.1 // Target: < 0.1s
    }
}
