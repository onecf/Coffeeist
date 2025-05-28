import Foundation
import FirebaseFirestore

struct UserSetup: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var brewingMethodId: String? // Optional reference to brewing_methods
    var equipmentIds: SetupEquipment
    var isDefault: Bool
    var isPublic: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        userId: String,
        name: String,
        brewingMethodId: String? = nil,
        equipmentIds: SetupEquipment = SetupEquipment(),
        isDefault: Bool = false,
        isPublic: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.userId = userId
        self.name = name
        self.brewingMethodId = brewingMethodId
        self.equipmentIds = equipmentIds
        self.isDefault = isDefault
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct SetupEquipment: Codable {
    var espressoMachine: String? // Equipment ID
    var grinder: String? // Equipment ID
    var portafilter: String? // Equipment ID
    var scale: String? // Equipment ID
    var kettle: String? // Equipment ID
    var dripper: String? // Equipment ID
    
    init(
        espressoMachine: String? = nil,
        grinder: String? = nil,
        portafilter: String? = nil,
        scale: String? = nil,
        kettle: String? = nil,
        dripper: String? = nil
    ) {
        self.espressoMachine = espressoMachine
        self.grinder = grinder
        self.portafilter = portafilter
        self.scale = scale
        self.kettle = kettle
        self.dripper = dripper
    }
    
    var hasAnyEquipment: Bool {
        return espressoMachine != nil || grinder != nil || portafilter != nil || 
               scale != nil || kettle != nil || dripper != nil
    }
    
    var equipmentCount: Int {
        var count = 0
        if espressoMachine != nil { count += 1 }
        if grinder != nil { count += 1 }
        if portafilter != nil { count += 1 }
        if scale != nil { count += 1 }
        if kettle != nil { count += 1 }
        if dripper != nil { count += 1 }
        return count
    }
} 