//
//  GroceryRecipeManagerTests.swift
//  GroceryRecipeManagerTests
//
//  Created by Rich Hayn on 8/18/25.
//

import XCTest
import CoreData
@testable import GroceryRecipeManager

final class GroceryRecipeManagerTests: XCTestCase {
    
    // Test-specific Core Data setup
    var testPersistenceController: PersistenceController!
    var testContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Create in-memory test persistence controller for Core Data tests
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        // Clean up test Core Data
        testPersistenceController = nil
        testContext = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: - Phase 1 Core Data Relationship Tests
    
    func testWeeklyListToGroceryListItemRelationship() throws {
        print("🧪 Testing WeeklyList ↔ GroceryListItem relationships...")
        
        // Create a WeeklyList
        let weeklyList = WeeklyList(context: testContext)
        weeklyList.id = UUID()
        weeklyList.name = "Test Weekly List"
        weeklyList.dateCreated = Date()
        weeklyList.isCompleted = false
        weeklyList.notes = "Test list for Phase 1"
        
        // Create GroceryListItems with the new categoryName attribute
        let item1 = GroceryListItem(context: testContext)
        item1.id = UUID()
        item1.name = "Test Bananas"
        item1.categoryName = "Produce" // NEW ATTRIBUTE
        item1.quantity = "2 bunches"
        item1.isCompleted = false
        item1.source = "test"
        item1.sortOrder = 0
        
        let item2 = GroceryListItem(context: testContext)
        item2.id = UUID()
        item2.name = "Test Milk"
        item2.categoryName = "Dairy & Fridge" // NEW ATTRIBUTE
        item2.quantity = "1 gallon"
        item2.isCompleted = false
        item2.source = "test"
        item2.sortOrder = 1
        
        let item3 = GroceryListItem(context: testContext)
        item3.id = UUID()
        item3.name = "Test Bread"
        item3.categoryName = "Bread & Frozen" // NEW ATTRIBUTE
        item3.quantity = "1 loaf"
        item3.isCompleted = true // This one is completed
        item3.source = "test"
        item3.sortOrder = 2
        
        // Set up relationships using the new relationship methods
        weeklyList.addToItems(item1)
        weeklyList.addToItems(item2)
        weeklyList.addToItems(item3)
        
        // Save the context
        do {
            try testContext.save()
            print("✅ Successfully saved test data to Core Data")
        } catch {
            XCTFail("Failed to save test context: \(error)")
            return
        }
        
        // Test 1: WeeklyList should have 3 items
        XCTAssertEqual(weeklyList.items?.count, 3, "WeeklyList should have 3 items")
        print("✅ WeeklyList has correct item count: \(weeklyList.items?.count ?? 0)")
        
        // Test 2: Each item should reference the correct weekly list
        XCTAssertEqual(item1.weeklyList, weeklyList, "Item1 should reference the weekly list")
        XCTAssertEqual(item2.weeklyList, weeklyList, "Item2 should reference the weekly list")
        XCTAssertEqual(item3.weeklyList, weeklyList, "Item3 should reference the weekly list")
        print("✅ All items correctly reference their weekly list")
        
        // Test 3: categoryName attribute should be properly stored
        XCTAssertEqual(item1.categoryName, "Produce", "Item1 should have Produce category")
        XCTAssertEqual(item2.categoryName, "Dairy & Fridge", "Item2 should have Dairy category")
        XCTAssertEqual(item3.categoryName, "Bread & Frozen", "Item3 should have Bread category")
        print("✅ All items have correct categoryName values")
        
        // Test 4: Test removing an item from the relationship
        weeklyList.removeFromItems(item2)
        XCTAssertEqual(weeklyList.items?.count, 2, "WeeklyList should have 2 items after removal")
        XCTAssertNil(item2.weeklyList, "Item2 should no longer reference the weekly list")
        print("✅ Item removal works correctly")
        
        // Test 5: Test fetching items by category (simulating what we'll do in Phase 2)
        let allItems = weeklyList.items as? Set<GroceryListItem> ?? []
        let produceItems = allItems.filter { $0.categoryName == "Produce" }
        let completedItems = allItems.filter { $0.isCompleted }
        
        XCTAssertEqual(produceItems.count, 1, "Should have 1 produce item")
        XCTAssertEqual(completedItems.count, 1, "Should have 1 completed item")
        print("✅ Category and completion filtering works")
        
        print("🎉 All Phase 1 Core Data relationship tests passed!")
    }
    
    func testCascadeDelete() throws {
        print("🧪 Testing cascade delete behavior...")
        
        // Create a WeeklyList with items
        let weeklyList = WeeklyList(context: testContext)
        weeklyList.id = UUID()
        weeklyList.name = "Delete Test List"
        weeklyList.dateCreated = Date()
        weeklyList.isCompleted = false
        
        let item = GroceryListItem(context: testContext)
        item.id = UUID()
        item.name = "Delete Test Item"
        item.categoryName = "Test Category"
        item.quantity = "1"
        item.isCompleted = false
        item.source = "test"
        weeklyList.addToItems(item)
        
        try testContext.save()
        
        // Verify item exists
        let itemFetchRequest: NSFetchRequest<GroceryListItem> = GroceryListItem.fetchRequest()
        let itemsBefore = try testContext.fetch(itemFetchRequest)
        XCTAssertEqual(itemsBefore.count, 1, "Should have 1 item before delete")
        print("✅ Item exists before delete: \(itemsBefore.count)")
        
        // Delete the WeeklyList (should cascade delete the item)
        testContext.delete(weeklyList)
        try testContext.save()
        
        // Verify item was cascade deleted
        let itemsAfter = try testContext.fetch(itemFetchRequest)
        XCTAssertEqual(itemsAfter.count, 0, "Should have 0 items after cascade delete")
        print("✅ Cascade delete works correctly - items after delete: \(itemsAfter.count)")
        
        print("🎉 Cascade delete test passed!")
    }
    
    func testWeeklyListAccessorMethods() throws {
        print("🧪 Testing WeeklyList accessor methods...")
        
        let weeklyList = WeeklyList(context: testContext)
        weeklyList.id = UUID()
        weeklyList.name = "Accessor Test List"
        weeklyList.dateCreated = Date()
        
        let item1 = GroceryListItem(context: testContext)
        item1.id = UUID()
        item1.name = "Item 1"
        item1.categoryName = "Category A"
        
        let item2 = GroceryListItem(context: testContext)
        item2.id = UUID()
        item2.name = "Item 2"
        item2.categoryName = "Category B"
        
        // Test addToItems method
        weeklyList.addToItems(item1)
        XCTAssertEqual(weeklyList.items?.count, 1, "Should have 1 item after adding")
        
        // Test adding multiple items using NSSet
        let itemSet = NSSet(array: [item2])
        weeklyList.addToItems(itemSet)
        XCTAssertEqual(weeklyList.items?.count, 2, "Should have 2 items after adding set")
        
        // Test removeFromItems method
        weeklyList.removeFromItems(item1)
        XCTAssertEqual(weeklyList.items?.count, 1, "Should have 1 item after removal")
        
        try testContext.save()
        print("✅ All accessor methods work correctly")
    }
}
