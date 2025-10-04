//
//  IngredientAutocompleteService.swift
//  GroceryRecipeManager
//
//  Created for M2.3: Recipe Creation & Editing
//  Parse-then-autocomplete pattern for intelligent ingredient matching
//

import Foundation
import CoreData
import Combine

class IngredientAutocompleteService: ObservableObject {
    private let context: NSManagedObjectContext
    private let parsingService: IngredientParsingService
    
    @Published var suggestions: [IngredientTemplate] = []
    @Published var lastSearchDuration: TimeInterval = 0
    
    private var searchCancellable: AnyCancellable?
    
    init(context: NSManagedObjectContext, parsingService: IngredientParsingService) {
        self.context = context
        self.parsingService = parsingService
    }
    
    // MARK: - Parse-Then-Autocomplete (Core Pattern)
    
    /// Main search method: Parse full text, then autocomplete on ingredient name
    func searchIngredients(fullText: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard fullText.count >= 2 else {
            suggestions = []
            return
        }
        
        // Step 1: Parse to extract ingredient name
        let parsed = parsingService.parseIngredient(text: fullText)
        let ingredientName = parsed.name
        
        guard ingredientName.count >= 2 else {
            suggestions = []
            return
        }
        
        // Step 2: Multi-pass search on ingredient name only
        var results: [IngredientTemplate] = []
        let query = ingredientName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Pass 1: Exact prefix match (highest priority)
        results.append(contentsOf: exactPrefixMatch(query: query))
        
        // Pass 2: Word boundary match
        if results.count < 10 {
            results.append(contentsOf: wordBoundaryMatch(query: query))
        }
        
        // Pass 3: Contains match
        if results.count < 10 {
            results.append(contentsOf: containsMatch(query: query))
        }
        
        // Pass 4: Fuzzy match (Levenshtein distance <= 2)
        if results.count < 10 {
            results.append(contentsOf: fuzzyMatch(query: query))
        }
        
        // Remove duplicates and limit to 10
        suggestions = uniqueTemplates(results).prefix(10).map { $0 }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        lastSearchDuration = duration
    }
    
    /// Debounced search (0.3s delay)
    func debouncedSearch(fullText: String) {
        searchCancellable?.cancel()
        
        searchCancellable = Just(fullText)
            .delay(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.searchIngredients(fullText: text)
            }
    }
    
    // MARK: - Multi-Pass Search Implementation
    
    private func exactPrefixMatch(query: String) -> [IngredientTemplate] {
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", query)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ]
        request.fetchLimit = 10
        
        return (try? context.fetch(request)) ?? []
    }
    
    private func wordBoundaryMatch(query: String) -> [IngredientTemplate] {
        // Match words that start with query
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", " \(query)")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ]
        request.fetchLimit = 10
        
        return (try? context.fetch(request)) ?? []
    }
    
    private func containsMatch(query: String) -> [IngredientTemplate] {
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ]
        request.fetchLimit = 10
        
        return (try? context.fetch(request)) ?? []
    }
    
    private func fuzzyMatch(query: String) -> [IngredientTemplate] {
        // Get all templates and filter by Levenshtein distance
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IngredientTemplate.usageCount, ascending: false)
        ]
        
        let allTemplates = (try? context.fetch(request)) ?? []
        
        return allTemplates.filter { template in
            guard let name = template.name else { return false }
            let distance = levenshteinDistance(query.lowercased(), name.lowercased())
            return distance <= 2
        }.prefix(10).map { $0 }
    }
    
    // MARK: - Helper Methods
    
    private func uniqueTemplates(_ templates: [IngredientTemplate]) -> [IngredientTemplate] {
        var seen = Set<NSManagedObjectID>()
        return templates.filter { template in
            let id = template.objectID
            if seen.contains(id) {
                return false
            } else {
                seen.insert(id)
                return true
            }
        }
    }
    
    /// Levenshtein distance for fuzzy matching
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let empty = [Int](repeating: 0, count: s2.count)
        var last = [Int](0...s2.count)
        
        for (i, char1) in s1.enumerated() {
            var cur = [i + 1] + empty
            for (j, char2) in s2.enumerated() {
                cur[j + 1] = char1 == char2 ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        return last.last ?? 0
    }
    
    // MARK: - Performance Validation
    
    func validatePerformance() -> Bool {
        let testText = "2 cups flour"
        searchIngredients(fullText: testText)
        return lastSearchDuration < 0.1 // Target: < 0.1s
    }
}//
//  IngredientAutocompleteService.swift
//  GroceryRecipeManager
//
//  Created by Richard Hayn on 10/3/25.
//

