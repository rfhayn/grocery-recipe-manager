//
//  PlannedMeal+Extensions.swift
//  forager
//
//  Created by Richard Hayn on 12/18/25.
//

import Foundation

extension PlannedMeal {
    
    // MARK: - M7.1.3 Semantic Key Helpers
    
    /// Generates slot key for semantic uniqueness (one meal per date+type)
    /// - Parameters:
    ///   - date: The date of the meal
    ///   - mealType: The type of meal (breakfast, lunch, dinner, snack)
    /// - Returns: Slot key in format "YYYY-MM-DD-mealType"
    static func generateSlotKey(date: Date, mealType: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate] // YYYY-MM-DD only
        let dateString = dateFormatter.string(from: date)
        return "\(dateString)-\(mealType)"
    }
}
