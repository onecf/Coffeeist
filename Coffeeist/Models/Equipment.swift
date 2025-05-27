import Foundation
import FirebaseFirestore

struct Equipment: Identifiable, Codable {
    @DocumentID var id: String?
    var type: EquipmentType
    var brand: String
    var model: String
    var specifications: EquipmentSpecifications?
    var imageURL: String?
    var category: String?
    var averageRating: Double
    var ratingCount: Int
    var createdBy: String
    var createdAt: Date
    var isVerified: Bool
    
    init(
        type: EquipmentType,
        brand: String,
        model: String,
        specifications: EquipmentSpecifications? = nil,
        imageURL: String? = nil,
        category: String? = nil,
        averageRating: Double = 0.0,
        ratingCount: Int = 0,
        createdBy: String,
        createdAt: Date = Date(),
        isVerified: Bool = false
    ) {
        self.type = type
        self.brand = brand
        self.model = model
        self.specifications = specifications
        self.imageURL = imageURL
        self.category = category
        self.averageRating = averageRating
        self.ratingCount = ratingCount
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.isVerified = isVerified
    }
    
    var displayName: String {
        return "\(brand) \(model)"
    }
}

enum EquipmentType: String, CaseIterable, Codable {
    case espressoMachine = "espresso_machine"
    case grinder = "grinder"
    case portafilter = "portafilter"
    case scale = "scale"
    case kettle = "kettle"
    case dripper = "dripper"
    case frenchPress = "french_press"
    case aeropress = "aeropress"
    case chemex = "chemex"
    case v60 = "v60"
    case kalita = "kalita"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .espressoMachine:
            return "Espresso Machine"
        case .grinder:
            return "Grinder"
        case .portafilter:
            return "Portafilter"
        case .scale:
            return "Scale"
        case .kettle:
            return "Kettle"
        case .dripper:
            return "Dripper"
        case .frenchPress:
            return "French Press"
        case .aeropress:
            return "AeroPress"
        case .chemex:
            return "Chemex"
        case .v60:
            return "V60"
        case .kalita:
            return "Kalita"
        case .other:
            return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .espressoMachine:
            return "cup.and.saucer.fill"
        case .grinder:
            return "gear"
        case .portafilter:
            return "circle.grid.cross.fill"
        case .scale:
            return "scalemass.fill"
        case .kettle:
            return "drop.fill"
        case .dripper, .v60, .kalita:
            return "triangle.fill"
        case .frenchPress:
            return "cylinder.fill"
        case .aeropress:
            return "capsule.fill"
        case .chemex:
            return "flask.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

struct EquipmentSpecifications: Codable {
    var size: String?
    var capacity: String?
    var features: [String]?
    var portafilterSize: String? // For portafilters
    var portafilterType: String? // For portafilters (bottomless, standard, etc.)
    var grinderType: String? // For grinders (burr, blade, etc.)
    var boilerType: String? // For espresso machines (single, dual, etc.)
    
    init(
        size: String? = nil,
        capacity: String? = nil,
        features: [String]? = nil,
        portafilterSize: String? = nil,
        portafilterType: String? = nil,
        grinderType: String? = nil,
        boilerType: String? = nil
    ) {
        self.size = size
        self.capacity = capacity
        self.features = features
        self.portafilterSize = portafilterSize
        self.portafilterType = portafilterType
        self.grinderType = grinderType
        self.boilerType = boilerType
    }
} 