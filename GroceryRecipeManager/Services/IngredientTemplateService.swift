import Foundation
import CoreData

class IngredientTemplateService: ObservableObject {
    private let context: NSManagedObjectContext
    
    @Published var lastSearchDuration: TimeInterval = 0
    @Published var popularIngredients: [IngredientTemplate] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
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
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", name)
        
        do {
            if let existingTemplate = try context.fetch(request).first {
                return existingTemplate
            }
        } catch {
            print("Error searching for existing template: \(error)")
        }
        
        let newTemplate = IngredientTemplate(context: context)
        newTemplate.id = UUID()
        newTemplate.name = name
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
}
