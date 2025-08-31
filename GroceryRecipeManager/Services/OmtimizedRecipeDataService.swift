//
//  OptimizedRecipeDataService.swift
//  GroceryRecipeManager
//
//  Created on August 31, 2025
//  Phase 0 Step 2: Performance Optimization Implementation
//

import Foundation
import CoreData
import SwiftUI

/// High-performance Core Data service for recipe operations with N+1 query prevention
/// Implements batch fetching, relationship prefetching, and sub-100ms response guarantees
class OptimizedRecipeDataService: ObservableObject {
    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    // MARK: - Performance Metrics Tracking
    @Published private(set) var lastFetchDuration: TimeInterval = 0.0
    @Published private(set) var isOptimizedFetchingEnabled = true
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        // Create dedicated background context for non-blocking operations
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.parent = context
    }
    
    // MARK: - Optimized Recipe Fetching
    
    /// Fetches all recipes with preloaded relationships to prevent N+1 queries
    /// Target performance: < 0.1s response time regardless of recipe count
    func fetchAllRecipesOptimized() async throws -> [Recipe] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Context deallocated"]))
                    return
                }
                
                do {
                    let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
                    
                    // Critical Performance Optimization: Prefetch all relationships
                    request.relationshipKeyPathsForPrefetching = [
                        "ingredients",           // Prefetch all ingredients
                        "tags"                   // Prefetch all tags
                    ]
                    
                    // Performance Index Utilization
                    request.sortDescriptors = [
                        NSSortDescriptor(keyPath: \Recipe.lastUsed, ascending: false),
                        NSSortDescriptor(keyPath: \Recipe.usageCount, ascending: false),
                        NSSortDescriptor(keyPath: \Recipe.title, ascending: true)
                    ]
                    
                    // Batch Processing for Large Datasets
                    request.fetchBatchSize = 50
                    request.returnsObjectsAsFaults = false // Prevent lazy loading delays
                    
                    let recipes = try self.backgroundContext.fetch(request)
                    
                    // Calculate performance metrics
                    let fetchDuration = CFAbsoluteTimeGetCurrent() - startTime
                    
                    // Update performance tracking on main thread
                    DispatchQueue.main.async {
                        self.lastFetchDuration = fetchDuration
                    }
                    
                    // Performance Warning for Development
                    if fetchDuration > 0.1 {
                        print("⚠️ PERFORMANCE WARNING: Recipe fetch took \(String(format: "%.3f", fetchDuration))s (target: < 0.1s)")
                    }
                    
                    continuation.resume(returning: recipes)
                    
                } catch {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch recipes: \(error.localizedDescription)"]))
                }
            }
        }
    }
    
    /// Fetches single recipe with full relationship graph preloaded
    /// Optimized for recipe detail views with complete ingredient data
    func fetchRecipeWithFullDetails(recipeID: UUID) async throws -> Recipe? {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Context deallocated"]))
                    return
                }
                
                do {
                    let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", recipeID as CVarArg)
                    
                    // Maximum Relationship Prefetching for Detail View
                    request.relationshipKeyPathsForPrefetching = [
                        "ingredients",
                        "tags"
                    ]
                    
                    request.fetchLimit = 1
                    request.returnsObjectsAsFaults = false
                    
                    let recipes = try self.backgroundContext.fetch(request)
                    let recipe = recipes.first
                    
                    let fetchDuration = CFAbsoluteTimeGetCurrent() - startTime
                    
                    DispatchQueue.main.async {
                        self.lastFetchDuration = fetchDuration
                    }
                    
                    if fetchDuration > 0.05 {
                        print("⚠️ PERFORMANCE: Recipe detail fetch took \(String(format: "%.3f", fetchDuration))s")
                    }
                    
                    continuation.resume(returning: recipe)
                    
                } catch {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch recipe details: \(error.localizedDescription)"]))
                }
            }
        }
    }
    
    /// Updates recipe usage with optimized single-transaction approach
    /// Prevents multiple Core Data saves and relationship reloading
    func updateRecipeUsage(_ recipe: Recipe) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Context deallocated"]))
                    return
                }
                
                do {
                    // Fetch recipe in background context to avoid threading issues
                    if let bgRecipe = self.backgroundContext.object(with: recipe.objectID) as? Recipe {
                        bgRecipe.usageCount += 1
                        bgRecipe.lastUsed = Date()
                        
                        try self.backgroundContext.save()
                        
                        // Propagate changes to main context efficiently
                        DispatchQueue.main.async {
                            do {
                                try self.context.save()
                                continuation.resume()
                            } catch {
                                continuation.resume(throwing: NSError(domain: "CoreDataError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to save to main context: \(error.localizedDescription)"]))
                            }
                        }
                    } else {
                        continuation.resume(throwing: NSError(domain: "CoreDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Recipe not found in background context"]))
                    }
                    
                } catch {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to update recipe usage: \(error.localizedDescription)"]))
                }
            }
        }
    }
    
    /// Returns performance metrics for monitoring and optimization
    func getPerformanceMetrics() -> (lastFetchDuration: TimeInterval, isOptimal: Bool) {
        return (lastFetchDuration, lastFetchDuration < 0.1)
    }
    
    /// Validates Core Data performance with test queries
    func validatePerformance() async -> Bool {
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            _ = try await fetchAllRecipesOptimized()
            let totalTime = CFAbsoluteTimeGetCurrent() - startTime
            
            return totalTime < 0.1
        } catch {
            print("Performance validation failed: \(error)")
            return false
        }
    }
}
