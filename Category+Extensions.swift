//
//  Category+Extensions.swift
//  forager
//
//  Created by Richard Hayn on 12/18/25.
//

import Foundation

extension Category {
    
    // MARK: - M7.1.3 Semantic Key Helpers
    
    /// Generates normalized category name for semantic uniqueness
    /// - Parameter name: The display name of the category
    /// - Returns: Lowercase, trimmed version of the name
    static func normalizedName(from name: String) -> String {
        return name
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
