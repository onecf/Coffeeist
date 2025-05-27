import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    // MARK: - User Management
    func createUser(_ user: User) async throws {
        print("🔄 DatabaseService: Creating user document for UID: \(user.uid)")
        print("🔄 DatabaseService: User data - Email: \(user.email), DisplayName: \(user.displayName)")
        
        do {
            try await db.collection("users").document(user.uid).setData(from: user)
            print("✅ DatabaseService: Successfully created user document")
        } catch {
            print("❌ DatabaseService: Failed to create user document: \(error)")
            print("❌ DatabaseService: Error details: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getUser(uid: String) async throws -> User? {
        let document = try await db.collection("users").document(uid).getDocument()
        
        // Check if document exists and has data
        guard document.exists, document.data() != nil else {
            return nil
        }
        
        return try document.data(as: User.self)
    }
    
    func updateUser(_ user: User) async throws {
        // Use the uid field, not the id field (which is the Firestore document ID)
        try await db.collection("users").document(user.uid).setData(from: user, merge: true)
    }
    
    func getCurrentUser() async throws -> User? {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return try await getUser(uid: currentUser.uid)
    }
    
    // MARK: - Coffee Beans
    func createCoffeeBean(_ coffeeBean: CoffeeBean) async throws -> String {
        let docRef = try await db.collection("coffee_beans").addDocument(from: coffeeBean)
        return docRef.documentID
    }
    
    func getCoffeeBeans(limit: Int = 50) async throws -> [CoffeeBean] {
        let snapshot = try await db.collection("coffee_beans")
            .order(by: "averageRating", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: CoffeeBean.self) }
    }
    
    func searchCoffeeBeans(query: String) async throws -> [CoffeeBean] {
        // Simple text search - in production, consider using Algolia or similar
        let snapshot = try await db.collection("coffee_beans")
            .whereField("brand", isGreaterThanOrEqualTo: query)
            .whereField("brand", isLessThan: query + "\u{f8ff}")
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: CoffeeBean.self) }
    }
    
    func getCoffeeBean(id: String) async throws -> CoffeeBean? {
        let document = try await db.collection("coffee_beans").document(id).getDocument()
        return try document.data(as: CoffeeBean.self)
    }
    
    // MARK: - Equipment
    func createEquipment(_ equipment: Equipment) async throws -> String {
        let docRef = try await db.collection("equipment").addDocument(from: equipment)
        return docRef.documentID
    }
    
    func getEquipment(type: EquipmentType? = nil, limit: Int = 50) async throws -> [Equipment] {
        var query: Query = db.collection("equipment")
        
        if let type = type {
            query = query.whereField("type", isEqualTo: type.rawValue)
        }
        
        let snapshot = try await query
            .order(by: "averageRating", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: Equipment.self) }
    }
    
    func searchEquipment(query: String, type: EquipmentType? = nil) async throws -> [Equipment] {
        var firestoreQuery: Query = db.collection("equipment")
        
        if let type = type {
            firestoreQuery = firestoreQuery.whereField("type", isEqualTo: type.rawValue)
        }
        
        let snapshot = try await firestoreQuery
            .whereField("brand", isGreaterThanOrEqualTo: query)
            .whereField("brand", isLessThan: query + "\u{f8ff}")
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: Equipment.self) }
    }
    
    // MARK: - Brewing Methods
    func createBrewingMethod(_ method: BrewingMethod) async throws -> String {
        let docRef = try await db.collection("brewing_methods").addDocument(from: method)
        return docRef.documentID
    }
    
    func getBrewingMethods() async throws -> [BrewingMethod] {
        let snapshot = try await db.collection("brewing_methods")
            .order(by: "name")
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: BrewingMethod.self) }
    }
    
    func getBrewingMethod(id: String) async throws -> BrewingMethod? {
        let document = try await db.collection("brewing_methods").document(id).getDocument()
        return try document.data(as: BrewingMethod.self)
    }
    
    // MARK: - User Setups
    func createUserSetup(_ setup: UserSetup) async throws -> String {
        let docRef = try await db.collection("user_setups").addDocument(from: setup)
        return docRef.documentID
    }
    
    func getUserSetups(userId: String) async throws -> [UserSetup] {
        let snapshot = try await db.collection("user_setups")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: UserSetup.self) }
    }
    
    func getDefaultUserSetup(userId: String) async throws -> UserSetup? {
        let snapshot = try await db.collection("user_setups")
            .whereField("userId", isEqualTo: userId)
            .whereField("isDefault", isEqualTo: true)
            .limit(to: 1)
            .getDocuments()
        
        return try snapshot.documents.first?.data(as: UserSetup.self)
    }
    
    func updateUserSetup(_ setup: UserSetup) async throws {
        guard let id = setup.id else { throw DatabaseError.invalidData }
        try await db.collection("user_setups").document(id).setData(from: setup, merge: true)
    }
    
    // MARK: - User Coffee Inventory
    func addCoffeeToInventory(_ inventory: UserCoffeeInventory) async throws -> String {
        let docRef = try await db.collection("user_coffee_inventory").addDocument(from: inventory)
        return docRef.documentID
    }
    
    func getUserCoffeeInventory(userId: String, includeFinished: Bool = false) async throws -> [UserCoffeeInventory] {
        var query: Query = db.collection("user_coffee_inventory")
            .whereField("userId", isEqualTo: userId)
        
        if !includeFinished {
            query = query.whereField("isFinished", isEqualTo: false)
        }
        
        let snapshot = try await query
            .order(by: "purchaseDate", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: UserCoffeeInventory.self) }
    }
    
    func updateCoffeeInventory(_ inventory: UserCoffeeInventory) async throws {
        guard let id = inventory.id else { throw DatabaseError.invalidData }
        try await db.collection("user_coffee_inventory").document(id).setData(from: inventory, merge: true)
    }
    
    // MARK: - User Coffee Wishlist
    func addCoffeeToWishlist(_ wishlist: UserCoffeeWishlist) async throws -> String {
        let docRef = try await db.collection("user_coffee_wishlist").addDocument(from: wishlist)
        return docRef.documentID
    }
    
    func getUserCoffeeWishlist(userId: String) async throws -> [UserCoffeeWishlist] {
        let snapshot = try await db.collection("user_coffee_wishlist")
            .whereField("userId", isEqualTo: userId)
            .order(by: "priority", descending: true)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: UserCoffeeWishlist.self) }
    }
    
    func removeCoffeeFromWishlist(id: String) async throws {
        try await db.collection("user_coffee_wishlist").document(id).delete()
    }
    
    // MARK: - User Equipment Owned
    func addEquipmentToOwned(_ equipment: UserEquipmentOwned) async throws -> String {
        let docRef = try await db.collection("user_equipment_owned").addDocument(from: equipment)
        return docRef.documentID
    }
    
    func getUserOwnedEquipment(userId: String) async throws -> [UserEquipmentOwned] {
        let snapshot = try await db.collection("user_equipment_owned")
            .whereField("userId", isEqualTo: userId)
            .order(by: "isCurrentlyUsing", descending: true)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: UserEquipmentOwned.self) }
    }
    
    // MARK: - Preparations (Enhanced)
    func createPreparation(_ preparation: Preparation) async throws -> String {
        let docRef = try await db.collection("preparations").addDocument(from: preparation)
        return docRef.documentID
    }
    
    func getUserPreparations(userId: String, limit: Int = 50) async throws -> [Preparation] {
        let snapshot = try await db.collection("preparations")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: Preparation.self) }
    }
    
    func getPublicPreparations(limit: Int = 50) async throws -> [Preparation] {
        let snapshot = try await db.collection("preparations")
            .whereField("isPublic", isEqualTo: true)
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: Preparation.self) }
    }
    
    func updatePreparation(_ preparation: Preparation) async throws {
        guard let id = preparation.id else { throw DatabaseError.invalidData }
        var updatedPreparation = preparation
        updatedPreparation.updatedAt = Date()
        try await db.collection("preparations").document(id).setData(from: updatedPreparation, merge: true)
    }
    
    func deletePreparation(id: String) async throws {
        try await db.collection("preparations").document(id).delete()
    }
    
    // MARK: - Community Features
    func followUser(follower: String, following: String) async throws {
        let follow = Follow(follower: follower, following: following)
        try await db.collection("follows").addDocument(from: follow)
        
        // Update follower/following counts
        try await updateFollowCounts(userId: follower, isFollowing: true)
        try await updateFollowCounts(userId: following, isFollower: true)
    }
    
    func unfollowUser(follower: String, following: String) async throws {
        let snapshot = try await db.collection("follows")
            .whereField("follower", isEqualTo: follower)
            .whereField("following", isEqualTo: following)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
        
        // Update follower/following counts
        try await updateFollowCounts(userId: follower, isFollowing: false)
        try await updateFollowCounts(userId: following, isFollower: false)
    }
    
    private func updateFollowCounts(userId: String, isFollowing: Bool? = nil, isFollower: Bool? = nil) async throws {
        let userRef = db.collection("users").document(userId)
        
        if let isFollowing = isFollowing {
            try await userRef.updateData([
                "followingCount": FieldValue.increment(Int64(isFollowing ? 1 : -1))
            ])
        }
        
        if let isFollower = isFollower {
            try await userRef.updateData([
                "followersCount": FieldValue.increment(Int64(isFollower ? 1 : -1))
            ])
        }
    }
    
    // MARK: - Data Seeding
    func seedDefaultBrewingMethods() async throws {
        let existingMethods = try await getBrewingMethods()
        if existingMethods.isEmpty {
            for method in BrewingMethod.defaultMethods {
                _ = try await createBrewingMethod(method)
            }
        }
    }
    
    func seedDefaultCoffeeBeans(createdBy: String) async throws {
        let existingBeans = try await getCoffeeBeans(limit: 10)
        if existingBeans.isEmpty {
            for bean in CoffeeBean.defaultBeans(createdBy: createdBy) {
                _ = try await createCoffeeBean(bean)
            }
        }
    }
}

enum DatabaseError: Error {
    case invalidData
    case userNotFound
    case unauthorized
    
    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Invalid data provided"
        case .userNotFound:
            return "User not found"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
} 