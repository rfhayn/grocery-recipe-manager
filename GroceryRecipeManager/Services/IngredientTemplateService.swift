import Foundation
import CoreData

class IngredientTemplateService: ObservableObject {
    private let context: NSManagedObjectContext
    
    @Published var lastSearchDuration: TimeInterval = 0
    @Published var popularIngredients: [IngredientTemplate] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - M4.3.5: Ingredient Normalization
    
    // Phase 1: Case Normalization
    // Normalizes ingredient names to lowercase for consistent template matching
    // This eliminates duplicates like "Butter", "butter", "BUTTER"
    private func normalizeCase(_ name: String) -> String {
        return name.lowercased()
    }
    
    // Main normalization entry point
    // Currently only Phase 1 (case), will be extended with additional phases
    private func normalize(name: String) -> String {
        var normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized = normalizeCase(normalized)
        return normalized
    }
    
    // MARK: - Template Operations
    
    func searchTemplates(query: String, limit: Int = 10) -> [IngredientTemplate] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ]
        
        request.fetchLimit = limit
        
        do {
            let templates = try context.fetch(request)
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            self.lastSearchDuration = duration
            return templates
        } catch {
            print("Error searching ingredient templates: \(error)")
            return []
        }
    }
    
    func loadPopularIngredients(limit: Int = 20) -> [IngredientTemplate] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "usageCount > 0")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ]
        request.fetchLimit = limit
        
        do {
            let templates = try context.fetch(request)
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            self.lastSearchDuration = duration
            self.popularIngredients = templates
            return templates
        } catch {
            print("Error loading popular ingredients: \(error)")
            return []
        }
    }
    
    func findOrCreateTemplate(name: String, category: String? = nil) -> IngredientTemplate {
        // M4.3.5: Normalize ingredient name before lookup/creation
        let normalizedName = normalize(name: name)
        
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", normalizedName)
        
        do {
            if let existingTemplate = try context.fetch(request).first {
                return existingTemplate
            }
        } catch {
            print("Error searching for existing template: \(error)")
        }
        
        // M4.3.5: Store normalized name in template
        let newTemplate = IngredientTemplate(context: context)
        newTemplate.id = UUID()
        newTemplate.name = normalizedName
        newTemplate.category = category  // String assignment
        newTemplate.usageCount = 1
        newTemplate.dateCreated = Date()
        
        do {
            try context.save()
        } catch {
            print("Error saving new ingredient template: \(error)")
        }
        
        return newTemplate
    }
    
    func incrementUsage(template: IngredientTemplate) {
        template.usageCount += 1
        
        do {
            try context.save()
        } catch {
            print("Error updating template usage: \(error)")
        }
    }
    
    func validateSearchPerformance() -> Bool {
        let _ = searchTemplates(query: "a", limit: 5)
        return lastSearchDuration < 0.1
    }
    
    // MARK: - M4.3.5: Data Migration
    
    // Migrates existing templates to normalized names
    // Should be called once after Phase 1 deployment
    func migrateExistingTemplates() {
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        
        do {
            let templates = try context.fetch(request)
            var migratedCount = 0
            
            for template in templates {
                let normalizedName = normalize(name: template.name ?? "")
                if template.name != normalizedName {
                    template.name = normalizedName
                    migratedCount += 1
                }
            }
            
            if migratedCount > 0 {
                try context.save()
                print("M4.3.5 Phase 1: Migrated \(migratedCount) templates to normalized case")
            } else {
                print("M4.3.5 Phase 1: No templates needed migration")
            }
        } catch {
            print("Error migrating templates: \(error)")
        }
    }
}
