//
//  MigrationTestHelper.swift
//  forager
//
//  Created by Richard Hayn on 12/18/25.
//  M7.1.3 Phase 1.1 Part 4 - Testing utility
//

import Foundation

#if DEBUG
/// Temporary helper for testing migration in Part 4
/// Will be removed after Part 4 complete
struct MigrationTestHelper {
    
    /// Reset Stage A migration flag for testing
    static func resetStageAMigration() {
        UserDefaults.standard.removeObject(forKey: "M7.1.3_StageA_Migration_Completed")
        UserDefaults.standard.removeObject(forKey: "M7.1.3_StageA_Migration_Date")
        print("🔄 M7.1.3: Stage A migration flag reset for testing")
    }
    
    /// Check current migration status
    static func getMigrationStatus() -> String {
        let isComplete = UserDefaults.standard.bool(forKey: "M7.1.3_StageA_Migration_Completed")
        let date = UserDefaults.standard.object(forKey: "M7.1.3_StageA_Migration_Date") as? Date
        
        var status = "📊 M7.1.3 Stage A Migration Status:\n"
        status += "   Completed: \(isComplete ? "✅ YES" : "❌ NO")\n"
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            status += "   Date: \(formatter.string(from: date))\n"
        }
        
        return status
    }
}
#endif
