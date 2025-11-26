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
    
    // Phase 2: Singular/Plural Normalization
    // Converts plural ingredient names to singular form
    // Handles regular plurals (eggs → egg) and irregular plurals (children → child)
    // EXCEPTION: Preserves ingredients that are inherently plural (chocolate chips, sprinkles)
    private func normalizePlural(_ name: String) -> String {
        let lowercased = name.lowercased()
        
        // Preserve-plural list: ingredients that should always stay plural
        // These are items typically bought/used in plural form
        let alwaysPlural = [
            "chocolate chips",
            "sprinkles",
            "croutons",
            "noodles",
            "tortilla chips",
            "potato chips",
            "corn chips"
        ]
        
        // Check if this ingredient should stay plural
        if alwaysPlural.contains(lowercased) {
            return lowercased
        }
        
        // Irregular plurals mapping (check these next)
        let irregularPlurals: [String: String] = [
            "children": "child",
            "feet": "foot",
            "teeth": "tooth",
            "geese": "goose",
            "mice": "mouse",
            "people": "person",
            "men": "man",
            "women": "woman",
            "oxen": "ox"
        ]
        
        if let singular = irregularPlurals[lowercased] {
            return singular
        }
        
        // Regular plural patterns
        
        // Pattern 1: -ies → -y (berries → berry, cherries → cherry)
        if lowercased.hasSuffix("ies") && lowercased.count > 3 {
            let base = String(lowercased.dropLast(3))
            return base + "y"
        }
        
        // Pattern 2: -oes → -o (tomatoes → tomato, potatoes → potato)
        if lowercased.hasSuffix("oes") && lowercased.count > 3 {
            return String(lowercased.dropLast(2))
        }
        
        // Pattern 3: -ses → -s (glasses → glass)
        if lowercased.hasSuffix("ses") && lowercased.count > 3 {
            return String(lowercased.dropLast(2))
        }
        
        // Pattern 4: -ves → -f (knives → knife, loaves → loaf)
        if lowercased.hasSuffix("ves") && lowercased.count > 3 {
            let base = String(lowercased.dropLast(3))
            return base + "f"
        }
        
        // Pattern 5: -s → remove (eggs → egg, apples → apple)
        // BUT NOT: -ss words (grass, glass, etc.) or -us words (asparagus, hummus)
        if lowercased.hasSuffix("s") &&
           !lowercased.hasSuffix("ss") &&
           !lowercased.hasSuffix("us") &&
           lowercased.count > 1 {
            return String(lowercased.dropLast())
        }
        
        // No plural pattern matched, return as-is
        return lowercased
    }
    
    // Phase 3: Abbreviation Expansion
    // Expands common measurement abbreviations to full words
    // Handles tbsp → tablespoon, tsp → teaspoon, oz → ounce, etc.
    private func expandAbbreviations(_ name: String) -> String {
        // Abbreviation dictionary mapping short forms to full forms
        let abbreviationMap: [String: String] = [
            // Volume measurements
            "tbsp": "tablespoon",
            "tbs": "tablespoon",
            "tsp": "teaspoon",
            "c": "cup",
            "pt": "pint",
            "qt": "quart",
            "gal": "gallon",
            "fl oz": "fluid ounce",
            "ml": "milliliter",
            "l": "liter",
            
            // Weight measurements
            "oz": "ounce",
            "lb": "pound",
            "lbs": "pound",
            "g": "gram",
            "kg": "kilogram",
            
            // Other common abbreviations
            "pkg": "package",
            "env": "envelope"
        ]
        
        var result = name
        
        // Split into words for word-boundary matching
        let words = result.split(separator: " ").map(String.init)
        var replacedWords: [String] = []
        
        for word in words {
            // Check if word is an abbreviation
            if let fullForm = abbreviationMap[word.lowercased()] {
                replacedWords.append(fullForm)
            } else {
                replacedWords.append(word)
            }
        }
        
        return replacedWords.joined(separator: " ")
    }
    
    // Main normalization entry point
    // Applies all normalization phases to an ingredient name
    // Phase 1: Case normalization (lowercase)
    // Phase 2: Singular/plural normalization
    // Phase 3: Abbreviation expansion
    // Phase 4: Variation handling (future)
    private func normalize(name: String) -> String {
        var normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Phase 1: Case normalization
        normalized = normalizeCase(normalized)
        
        // Phase 2: Singular/plural normalization
        normalized = normalizePlural(normalized)
        
        // Phase 3: Abbreviation expansion
        normalized = expandAbbreviations(normalized)
        
        // Phase 4 will be added here
        
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
