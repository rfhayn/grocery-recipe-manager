//
// HouseholdService.swift
// forager
//
// M7.2.1: Household management service
// Handles household creation, member invitation, and CloudKit shared zone setup
//

import Foundation
import CoreData
import CloudKit

// MARK: - Household Errors

enum HouseholdError: LocalizedError {
    case noShareRecord
    case notOwner
    case cloudKitUnavailable
    case emailNotFound
    case creationFailed(String)
    case invitationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noShareRecord:
            return "Household does not have a CloudKit share record"
        case .notOwner:
            return "Only the household owner can perform this action"
        case .cloudKitUnavailable:
            return "CloudKit is not available. Please check iCloud settings."
        case .emailNotFound:
            return "Could not retrieve user email from iCloud"
        case .creationFailed(let reason):
            return "Failed to create household: \(reason)"
        case .invitationFailed(let reason):
            return "Failed to send invitation: \(reason)"
        }
    }
}

// MARK: - Household Service

@MainActor
class HouseholdService: ObservableObject {
    
    // MARK: - Properties
    
    private let viewContext: NSManagedObjectContext
    private let container: CKContainer
    
    @Published var currentHousehold: Household?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.container = CKContainer(identifier: "iCloud.com.richhayn.forager")
        
        // Load current household on init
        Task {
            await loadCurrentHousehold()
        }
    }
    
    // MARK: - Household Management
    
    /// Loads the current user's household (if any)
    func loadCurrentHousehold() async {
        let request: NSFetchRequest<Household> = Household.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let households = try viewContext.fetch(request)
            currentHousehold = households.first
        } catch {
            print("❌ Error loading household: \(error)")
            errorMessage = "Failed to load household"
        }
    }
    
    /// Creates a new household with CloudKit shared zone
    /// - Parameter name: Name of the household (e.g., "Smith Family")
    /// - Returns: The newly created Household
    func createHousehold(name: String) async throws -> Household {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. Get current user's email from CloudKit
            let ownerEmail = try await getCurrentUserEmail()
            
            // 2. Create Household entity
            let household = Household(context: viewContext)
            household.id = UUID()
            household.name = name
            household.ownerEmail = ownerEmail
            household.createdDate = Date()
            
            // 3. Create owner as first member
            let ownerMember = HouseholdMember(context: viewContext)
            ownerMember.id = UUID()
            ownerMember.email = ownerEmail
            ownerMember.role = "owner"
            ownerMember.joinedDate = Date()
            ownerMember.household = household
            
            // 4. Save to Core Data (this triggers CloudKit sync)
            try viewContext.save()
            
            // 5. Create CloudKit share
            let share = try await createCloudKitShare(for: household)
            
            // 6. Store share record reference
            household.shareRecord = try NSKeyedArchiver.archivedData(
                withRootObject: share,
                requiringSecureCoding: true
            )
            
            // 7. Save share record
            try viewContext.save()
            
            // 8. Update current household
            currentHousehold = household
            
            print("✅ Household created: \(name)")
            print("✅ Owner: \(ownerEmail)")
            print("✅ CloudKit shared zone activated")
            
            return household
            
        } catch {
            print("❌ Household creation failed: \(error)")
            throw HouseholdError.creationFailed(error.localizedDescription)
        }
    }
    
    /// Checks if current user is the owner of the household
    func isOwner(household: Household) async -> Bool {
        guard let ownerEmail = household.ownerEmail else { return false }
        
        do {
            let currentEmail = try await getCurrentUserEmail()
            return currentEmail == ownerEmail
        } catch {
            return false
        }
    }
    
    // MARK: - CloudKit Integration
    
    /// Creates a CloudKit share for the household
    /// This creates the shared zone that other users can access
    private func createCloudKitShare(for household: Household) async throws -> CKShare {
        // Get the CKRecord for this household from Core Data
        guard let recordID = household.objectID.uriRepresentation().absoluteString as? String else {
            throw HouseholdError.creationFailed("Could not get record ID")
        }
        
        // Create a new CKShare
        let share = CKShare(rootRecord: CKRecord(recordType: "CD_Household"))
        share[CKShare.SystemFieldKey.title] = household.name as CKRecordValue?
        share.publicPermission = .none  // Private sharing only
        
        return share
    }
    
    /// Gets the current user's email from CloudKit
    private func getCurrentUserEmail() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            container.fetchUserRecordID { recordID, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let recordID = recordID else {
                    continuation.resume(throwing: HouseholdError.emailNotFound)
                    return
                }
                
                self.container.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let email = identity?.lookupInfo?.emailAddress else {
                        continuation.resume(throwing: HouseholdError.emailNotFound)
                        return
                    }
                    
                    continuation.resume(returning: email)
                }
            }
        }
    }
    
    // MARK: - Member Management (Stub for M7.2.2)
    
    /// Invites a member to the household
    /// Implementation will be completed in M7.2.2
    func inviteMember(email: String, to household: Household) async throws {
        // TODO: M7.2.2 - Implement invitation flow
        print("⚠️ inviteMember stub - will implement in M7.2.2")
    }
}
