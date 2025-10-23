//
//  IngredientTemplateValidationTests.swift
//  GroceryRecipeManager
//
//  Created for M3.5 Phase 1 Task 3: Template Validation Testing
//  Date: October 22, 2025
//
//  Purpose: Test validation rules against existing IngredientTemplate data
//

import Foundation
import CoreData

class IngredientTemplateValidationTests {
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Main Validation Test
    
    /// Run validation against all existing IngredientTemplate entities
    func validateAllTemplates() -> ValidationReport {
        let fetchRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        
        var report = ValidationReport()
        
        do {
            let templates = try context.fetch(fetchRequest)
            report.totalTemplates = templates.count
            
            print("🔍 Validating \(templates.count) IngredientTemplate entities...")
            print("")
            
            for template in templates {
                validateSingleTemplate(template, report: &report)
            }
            
            report.printSummary()
            
        } catch {
            print("❌ Failed to fetch templates: \(error.localizedDescription)")
            report.errors.append(("Fetch Error", error.localizedDescription))
        }
        
        return report
    }
    
    // MARK: - Individual Template Validation
    
    private func validateSingleTemplate(_ template: IngredientTemplate, report: inout ValidationReport) {
        do {
            try template.validateTemplateData()
            report.validTemplates += 1
            
            // Check for warnings (non-fatal issues)
            checkForWarnings(template, report: &report)
            
        } catch let error as IngredientTemplate.ValidationError {
            report.invalidTemplates += 1
            let templateName = template.name ?? "Unknown"
            report.errors.append((templateName, error.localizedDescription ?? "Unknown error"))
            
            print("❌ Validation Error: \(templateName)")
            print("   Error: \(error.localizedDescription ?? "Unknown")")
            print("   Suggestion: \(error.recoverySuggestion ?? "None")")
            print("")
            
        } catch {
            report.invalidTemplates += 1
            let templateName = template.name ?? "Unknown"
            report.errors.append((templateName, error.localizedDescription))
            print("❌ Unexpected Error: \(templateName) - \(error)")
            print("")
        }
    }
    
    // MARK: - Warning Checks (Non-Fatal)
    
    private func checkForWarnings(_ template: IngredientTemplate, report: inout ValidationReport) {
        var warnings: [String] = []
        
        // Warning: No category assigned
        if !template.hasCategory {
            warnings.append("No category assigned (uncategorized)")
            report.uncategorizedTemplates += 1
        }
        
        // Warning: Never used
        if !template.hasBeenUsed {
            warnings.append("Never used (usage count = 0)")
            report.unusedTemplates += 1
        }
        
        // Info: Frequently used
        if template.isFrequentlyUsed {
            report.frequentlyUsedTemplates += 1
        }
        
        // Info: Staple item
        if template.isStapleItem {
            report.stapleTemplates += 1
        }
        
        // Print warnings if any
        if !warnings.isEmpty {
            print("⚠️ Warnings for '\(template.displayName)':")
            for warning in warnings {
                print("   - \(warning)")
            }
            print("")
        }
    }
    
    // MARK: - Specific Validation Tests
    
    /// Test name validation rules
    func testNameValidation() {
        print("🧪 Testing name validation rules...")
        
        // Test 1: Empty name
        testValidation(name: "", shouldPass: false, testName: "Empty name")
        
        // Test 2: Too short name
        testValidation(name: "a", shouldPass: false, testName: "Too short (1 char)")
        
        // Test 3: Valid short name
        testValidation(name: "ab", shouldPass: true, testName: "Valid short (2 chars)")
        
        // Test 4: Valid normal name
        testValidation(name: "all-purpose flour", shouldPass: true, testName: "Valid normal name")
        
        // Test 5: Too long name (>100 chars)
        let longName = String(repeating: "a", count: 101)
        testValidation(name: longName, shouldPass: false, testName: "Too long (101 chars)")
        
        // Test 6: Exact limit name (100 chars)
        let limitName = String(repeating: "a", count: 100)
        testValidation(name: limitName, shouldPass: true, testName: "At limit (100 chars)")
        
        print("✅ Name validation tests complete")
        print("")
    }
    
    /// Test category validation rules
    func testCategoryValidation() {
        print("🧪 Testing category validation rules...")
        
        // Test 1: Nil category (uncategorized) - should pass
        testValidation(name: "test ingredient", category: nil, shouldPass: true, testName: "Nil category")
        
        // Test 2: Valid category
        testValidation(name: "test ingredient", category: "Produce", shouldPass: true, testName: "Valid category")
        
        // Test 3: Empty string category - should fail
        testValidation(name: "test ingredient", category: "", shouldPass: false, testName: "Empty category string")
        
        // Test 4: Whitespace only category - should fail
        testValidation(name: "test ingredient", category: "   ", shouldPass: false, testName: "Whitespace only")
        
        // Test 5: Too long category (>50 chars)
        let longCategory = String(repeating: "a", count: 51)
        testValidation(name: "test ingredient", category: longCategory, shouldPass: false, testName: "Too long category")
        
        print("✅ Category validation tests complete")
        print("")
    }
    
    /// Test usage count validation
    func testUsageCountValidation() {
        print("🧪 Testing usage count validation...")
        
        // Test 1: Zero usage count - valid
        testValidation(name: "test", usageCount: 0, shouldPass: true, testName: "Zero usage")
        
        // Test 2: Normal usage count
        testValidation(name: "test", usageCount: 5, shouldPass: true, testName: "Normal usage (5)")
        
        // Test 3: High usage count
        testValidation(name: "test", usageCount: 100, shouldPass: true, testName: "High usage (100)")
        
        // Test 4: At limit (10,000)
        testValidation(name: "test", usageCount: 10000, shouldPass: true, testName: "At limit (10,000)")
        
        // Test 5: Over limit
        testValidation(name: "test", usageCount: 10001, shouldPass: false, testName: "Over limit (10,001)")
        
        print("✅ Usage count validation tests complete")
        print("")
    }
    
    // MARK: - Helper Methods
    
    private func testValidation(
        name: String,
        category: String? = "Test Category",
        usageCount: Int32 = 0,
        shouldPass: Bool,
        testName: String
    ) {
        let template = IngredientTemplate(context: context)
        template.id = UUID()
        template.name = name
        template.category = category
        template.usageCount = usageCount
        template.dateCreated = Date()
        template.isStaple = false
        
        do {
            try template.validateTemplateData()
            if shouldPass {
                print("   ✅ PASS: \(testName)")
            } else {
                print("   ❌ FAIL: \(testName) - Expected validation error but passed")
            }
        } catch {
            if !shouldPass {
                print("   ✅ PASS: \(testName) - Correctly caught error")
            } else {
                print("   ❌ FAIL: \(testName) - Unexpected error: \(error.localizedDescription)")
            }
        }
        
        // Clean up test template (don't save to database)
        context.delete(template)
    }
}

// MARK: - Validation Report

struct ValidationReport {
    var totalTemplates: Int = 0
    var validTemplates: Int = 0
    var invalidTemplates: Int = 0
    var uncategorizedTemplates: Int = 0
    var unusedTemplates: Int = 0
    var frequentlyUsedTemplates: Int = 0
    var stapleTemplates: Int = 0
    var errors: [(String, String)] = []
    
    mutating func printSummary() {
        print("")
        print("=" * 70)
        print("📊 VALIDATION REPORT SUMMARY")
        print("=" * 70)
        print("")
        print("Total Templates: \(totalTemplates)")
        print("✅ Valid: \(validTemplates) (\(percentage(validTemplates, of: totalTemplates))%)")
        print("❌ Invalid: \(invalidTemplates) (\(percentage(invalidTemplates, of: totalTemplates))%)")
        print("")
        print("📈 STATISTICS:")
        print("   • Uncategorized: \(uncategorizedTemplates) (\(percentage(uncategorizedTemplates, of: totalTemplates))%)")
        print("   • Never Used: \(unusedTemplates) (\(percentage(unusedTemplates, of: totalTemplates))%)")
        print("   • Frequently Used (10+): \(frequentlyUsedTemplates)")
        print("   • Staples: \(stapleTemplates)")
        print("")
        
        if errors.isEmpty {
            print("✨ NO VALIDATION ERRORS FOUND - All templates are valid!")
        } else {
            print("⚠️ ERRORS FOUND (\(errors.count)):")
            for (name, error) in errors {
                print("   • \(name): \(error)")
            }
        }
        
        print("")
        print("=" * 70)
    }
    
    private func percentage(_ value: Int, of total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int(Double(value) / Double(total) * 100)
    }
}

// MARK: - String Extension

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

// MARK: - Test Runner Function

/// Run all validation tests - call this from a view or test context
func runIngredientTemplateValidation(context: NSManagedObjectContext) {
    let tester = IngredientTemplateValidationTests(context: context)
    
    print("")
    print("🚀 STARTING INGREDIENT TEMPLATE VALIDATION")
    print("=" * 70)
    print("")
    
    // Run individual validation rule tests
    tester.testNameValidation()
    tester.testCategoryValidation()
    tester.testUsageCountValidation()
    
    // Run validation against all existing templates
    let report = tester.validateAllTemplates()
    
    // Return report for further analysis if needed
    print("")
    print("🏁 VALIDATION COMPLETE")
    print("")
}
