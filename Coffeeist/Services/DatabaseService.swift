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
    
    // Get coffee beans that have been used in user's preparations
    func getUsedCoffeeBeans(userId: String) async throws -> [CoffeeBean] {
        print("☕ DatabaseService: Getting coffee beans used by user \(userId)...")
        
        // First, get all preparations for the user
        let preparationsSnapshot = try await db.collection("preparations")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        // Extract unique coffee bean IDs from preparations
        let coffeeBeanIds = Set<String>(preparationsSnapshot.documents.compactMap { document in
            guard let preparation = try? document.data(as: Preparation.self) else { return nil }
            return preparation.coffeeBeanId
        })
        
        print("☕ DatabaseService: Found \(coffeeBeanIds.count) unique coffee beans used in preparations")
        
        // If no coffee beans found, return empty array
        guard !coffeeBeanIds.isEmpty else {
            return []
        }
        
        // Fetch the actual coffee bean documents
        // Firestore 'in' queries are limited to 10 items, so we need to batch if more than 10
        let batchSize = 10
        let batchedIds = Array(coffeeBeanIds).chunked(into: batchSize)
        
        var allBeans: [CoffeeBean] = []
        
        for batch in batchedIds {
            let snapshot = try await db.collection("coffee_beans")
                .whereField(FieldPath.documentID(), in: Array(batch))
                .getDocuments()
            
            let beans = try snapshot.documents.compactMap { try $0.data(as: CoffeeBean.self) }
            allBeans.append(contentsOf: beans)
        }
        
        print("☕ DatabaseService: Successfully loaded \(allBeans.count) used coffee beans")
        return allBeans.sorted { $0.brand < $1.brand }
    }
    
    // Get equipment that have been used in user's preparations
    func getUsedEquipment(userId: String) async throws -> [Equipment] {
        print("⚙️ DatabaseService: Getting equipment used by user \(userId)...")
        
        // First, get all preparations for the user
        let preparationsSnapshot = try await db.collection("preparations")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        print("⚙️ DatabaseService: Found \(preparationsSnapshot.documents.count) preparations for user")
        
        // Extract unique equipment IDs from preparations
        var allEquipmentIds = Set<String>()
        var setupsFound = 0
        var setupsWithoutId = 0
        
        for document in preparationsSnapshot.documents {
            guard let preparation = try? document.data(as: Preparation.self) else { continue }
            
            // Add equipment IDs from the setup used in this preparation
            if let setupId = preparation.setupId {
                // Get the setup to extract equipment IDs
                do {
                    let setupDoc = try await db.collection("user_setups").document(setupId).getDocument()
                    if let setup = try? setupDoc.data(as: UserSetup.self) {
                        setupsFound += 1
                        var equipmentCountInSetup = 0
                        
                        // Add all equipment IDs from the setup
                        if let espressoMachineId = setup.equipmentIds.espressoMachine {
                            allEquipmentIds.insert(espressoMachineId)
                            equipmentCountInSetup += 1
                        }
                        if let grinderId = setup.equipmentIds.grinder {
                            allEquipmentIds.insert(grinderId)
                            equipmentCountInSetup += 1
                        }
                        if let portafilterId = setup.equipmentIds.portafilter {
                            allEquipmentIds.insert(portafilterId)
                            equipmentCountInSetup += 1
                        }
                        if let scaleId = setup.equipmentIds.scale {
                            allEquipmentIds.insert(scaleId)
                            equipmentCountInSetup += 1
                        }
                        if let kettleId = setup.equipmentIds.kettle {
                            allEquipmentIds.insert(kettleId)
                            equipmentCountInSetup += 1
                        }
                        if let dripperId = setup.equipmentIds.dripper {
                            allEquipmentIds.insert(dripperId)
                            equipmentCountInSetup += 1
                        }
                        
                        print("⚙️ Setup \(setupId) has \(equipmentCountInSetup) equipment items")
                    } else {
                        print("⚠️ Could not decode setup \(setupId) as UserSetup")
                    }
                } catch {
                    print("⚠️ Error fetching setup \(setupId): \(error)")
                }
            } else {
                print("⚠️ Preparation \(preparation.id ?? "unknown") has no setupId")
                setupsWithoutId += 1
            }
        }
        
        print("⚙️ DatabaseService: Processed \(setupsFound) setups, \(setupsWithoutId) preparations without setupId")
        print("⚙️ DatabaseService: Found \(allEquipmentIds.count) unique equipment IDs: \(Array(allEquipmentIds))")
        
        // If no equipment IDs found, return empty array
        if allEquipmentIds.isEmpty {
            print("⚙️ DatabaseService: No equipment found in user preparations")
            return []
        }
        
        // Fetch the actual equipment documents
        // Firestore 'in' queries are limited to 10 items, so we need to batch if more than 10
        let batchSize = 10
        let batchedIds = Array(allEquipmentIds).chunked(into: batchSize)
        
        var allEquipment: [Equipment] = []
        
        for batch in batchedIds {
            let batchSnapshot = try await db.collection("equipment")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments()
            
            let batchEquipment = batchSnapshot.documents.compactMap { document in
                try? document.data(as: Equipment.self)
            }
            
            allEquipment.append(contentsOf: batchEquipment)
        }
        
        // Sort alphabetically by brand and model
        let sortedEquipment = allEquipment.sorted { first, second in
            if first.brand == second.brand {
                return first.model < second.model
            }
            return first.brand < second.brand
        }
        
        print("⚙️ DatabaseService: Successfully retrieved \(sortedEquipment.count) used equipment items")
        return sortedEquipment
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
        print("🌱 Checking if brewing methods need seeding...")
        let existingMethods = try await getBrewingMethods()
        print("📊 Found \(existingMethods.count) existing brewing methods")
        
        if existingMethods.isEmpty {
            print("🌱 Seeding default brewing methods...")
            for method in BrewingMethod.defaultMethods {
                let methodId = try await createBrewingMethod(method)
                print("✅ Created brewing method: \(method.name) with ID: \(methodId)")
            }
            print("✅ Finished seeding brewing methods")
        } else {
            print("ℹ️ Brewing methods already exist, skipping seeding")
            
            // Check for missing methods and add only those
            let existingNames = Set(existingMethods.map { $0.name })
            let missingMethods = BrewingMethod.defaultMethods.filter { !existingNames.contains($0.name) }
            
            if !missingMethods.isEmpty {
                print("🌱 Adding \(missingMethods.count) missing brewing methods...")
                for method in missingMethods {
                    let methodId = try await createBrewingMethod(method)
                    print("✅ Added missing brewing method: \(method.name) with ID: \(methodId)")
                }
            }
        }
    }
    
    func seedDefaultCoffeeBeans(createdBy: String) async throws {
        print("🌱 Checking if coffee beans need seeding...")
        let existingBeans = try await getCoffeeBeans(limit: 100)
        print("📊 Found \(existingBeans.count) existing coffee beans")
        
        if existingBeans.isEmpty {
            print("🌱 Seeding default coffee beans...")
            let defaultBeans = CoffeeBean.defaultBeans(createdBy: createdBy)
            print("📦 Will create \(defaultBeans.count) coffee beans")
            
            for bean in defaultBeans {
                let beanId = try await createCoffeeBean(bean)
                print("✅ Created coffee bean: \(bean.brand) \(bean.name) with ID: \(beanId)")
            }
            print("✅ Finished seeding coffee beans")
        } else {
            print("ℹ️ Coffee beans already exist, checking for missing ones...")
            
            // Check for missing beans by brand + name combination
            let existingBeanKeys = Set(existingBeans.map { "\($0.brand)|\($0.name)" })
            let defaultBeans = CoffeeBean.defaultBeans(createdBy: createdBy)
            let missingBeans = defaultBeans.filter { !existingBeanKeys.contains("\($0.brand)|\($0.name)") }
            
            if !missingBeans.isEmpty {
                print("🌱 Adding \(missingBeans.count) missing coffee beans...")
                for bean in missingBeans {
                    let beanId = try await createCoffeeBean(bean)
                    print("✅ Added missing coffee bean: \(bean.brand) \(bean.name) with ID: \(beanId)")
                }
            } else {
                print("ℹ️ All default coffee beans already exist")
            }
        }
    }
    
    func seedDefaultEquipment(createdBy: String) async throws {
        print("🌱 Checking if equipment needs seeding...")
        let existingEquipment = try await getEquipment(limit: 100)
        print("📊 Found \(existingEquipment.count) existing equipment items")
        
        if existingEquipment.isEmpty {
            print("🌱 Seeding default equipment...")
            let defaultEquipment = Equipment.defaultEquipment(createdBy: createdBy)
            print("📦 Will create \(defaultEquipment.count) equipment items")
            
            for equipment in defaultEquipment {
                let equipmentId = try await createEquipment(equipment)
                print("✅ Created equipment: \(equipment.brand) \(equipment.model) with ID: \(equipmentId)")
            }
            print("✅ Finished seeding equipment")
        } else {
            print("ℹ️ Equipment already exists, checking for missing items...")
            
            // Check for missing equipment by brand + model combination
            let existingEquipmentKeys = Set(existingEquipment.map { "\($0.brand)|\($0.model)" })
            let defaultEquipment = Equipment.defaultEquipment(createdBy: createdBy)
            let missingEquipment = defaultEquipment.filter { !existingEquipmentKeys.contains("\($0.brand)|\($0.model)") }
            
            if !missingEquipment.isEmpty {
                print("🌱 Adding \(missingEquipment.count) missing equipment items...")
                for equipment in missingEquipment {
                    let equipmentId = try await createEquipment(equipment)
                    print("✅ Added missing equipment: \(equipment.brand) \(equipment.model) with ID: \(equipmentId)")
                }
            } else {
                print("ℹ️ All default equipment already exists")
            }
        }
    }
    
    // MARK: - Force Seeding (for debugging)
    func forceSeedAllData(createdBy: String) async throws {
        print("🔄 Force seeding all data...")
        
        // Force seed brewing methods
        print("🌱 Force seeding brewing methods...")
        for method in BrewingMethod.defaultMethods {
            let methodId = try await createBrewingMethod(method)
            print("✅ Created brewing method: \(method.name) with ID: \(methodId)")
        }
        
        // Force seed coffee beans
        print("🌱 Force seeding coffee beans...")
        let defaultBeans = CoffeeBean.defaultBeans(createdBy: createdBy)
        for bean in defaultBeans {
            let beanId = try await createCoffeeBean(bean)
            print("✅ Created coffee bean: \(bean.brand) \(bean.name) with ID: \(beanId)")
        }
        
        // Force seed equipment
        print("🌱 Force seeding equipment...")
        let defaultEquipment = Equipment.defaultEquipment(createdBy: createdBy)
        for equipment in defaultEquipment {
            let equipmentId = try await createEquipment(equipment)
            print("✅ Created equipment: \(equipment.brand) \(equipment.model) with ID: \(equipmentId)")
        }
        
        print("✅ Force seeding completed!")
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

// Extension to chunk arrays for batch processing
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
} 