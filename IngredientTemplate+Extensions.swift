//
//  IngredientTemplate+Extensions.swift
//  forager
//
//  Created by Richard Hayn on 12/18/25.
//

import Foundation

extension IngredientTemplate {
    
    // MARK: - M7.1.3 Semantic Key Helpers
    
    /// Generates canonical ingredient name for semantic uniqueness
    /// - Parameter name: The display name of the ingredient
    /// - Returns: Lowercase, trimmed version of the name
    static func canonicalName(from name: String) -> String {
        return name
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
