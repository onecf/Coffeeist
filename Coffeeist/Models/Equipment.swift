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
    
    static func defaultEquipment(createdBy: String) -> [Equipment] {
        return [
            // MARK: - Breville Espresso Machines
            Equipment(
                type: .espressoMachine,
                brand: "Breville",
                model: "Barista Express",
                specifications: EquipmentSpecifications(
                    size: "12.5\" x 13.2\" x 15.8\"",
                    capacity: "2L water tank",
                    features: ["Built-in conical burr grinder", "15 bar pressure", "Pre-infusion", "Dual wall filter baskets", "360° swivel steam wand"],
                    boilerType: "Thermocoil"
                ),
                category: "Semi-Automatic",
                averageRating: 4.5,
                ratingCount: 1250,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .espressoMachine,
                brand: "Breville",
                model: "Barista Pro",
                specifications: EquipmentSpecifications(
                    size: "13.1\" x 15.5\" x 16.0\"",
                    capacity: "2L water tank",
                    features: ["Built-in conical burr grinder", "ThermoJet heating system", "3-second heat up", "LCD display", "30 grind settings"],
                    boilerType: "ThermoJet"
                ),
                category: "Semi-Automatic",
                averageRating: 4.6,
                ratingCount: 890,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .espressoMachine,
                brand: "Breville",
                model: "Bambino Plus",
                specifications: EquipmentSpecifications(
                    size: "7.6\" x 12.2\" x 12.1\"",
                    capacity: "1.4L water tank",
                    features: ["ThermoJet heating system", "3-second heat up", "Automatic milk frother", "4 milk temperatures", "3 milk textures"],
                    boilerType: "ThermoJet"
                ),
                category: "Automatic Milk",
                averageRating: 4.4,
                ratingCount: 670,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .espressoMachine,
                brand: "Breville",
                model: "Oracle Touch",
                specifications: EquipmentSpecifications(
                    size: "17.5\" x 15.5\" x 18.1\"",
                    capacity: "2.5L water tank",
                    features: ["Touchscreen display", "Automatic grinding & tamping", "Dual boiler", "Auto milk texturing", "My Menu customization"],
                    boilerType: "Dual boiler"
                ),
                category: "Super-Automatic",
                averageRating: 4.7,
                ratingCount: 320,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .espressoMachine,
                brand: "Breville",
                model: "Dual Boiler",
                specifications: EquipmentSpecifications(
                    size: "16.0\" x 14.2\" x 15.8\"",
                    capacity: "2.5L water tank",
                    features: ["Dual stainless steel boilers", "PID temperature control", "Pre-infusion", "Shot clock", "Dry puck feature"],
                    boilerType: "Dual boiler"
                ),
                category: "Professional",
                averageRating: 4.8,
                ratingCount: 450,
                createdBy: createdBy,
                isVerified: true
            ),
            
            // MARK: - Baratza Grinders
            Equipment(
                type: .grinder,
                brand: "Baratza",
                model: "Encore",
                specifications: EquipmentSpecifications(
                    size: "5.3\" x 6.3\" x 13.8\"",
                    capacity: "8oz bean hopper",
                    features: ["40mm conical burrs", "40 grind settings", "Gear reduction motor", "Thermal protection", "Easy calibration"],
                    grinderType: "Conical burr"
                ),
                category: "Entry Level",
                averageRating: 4.3,
                ratingCount: 2100,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .grinder,
                brand: "Baratza",
                model: "Virtuoso+",
                specifications: EquipmentSpecifications(
                    size: "5.3\" x 6.3\" x 13.8\"",
                    capacity: "8oz bean hopper",
                    features: ["40mm conical burrs", "40 grind settings", "Digital timer", "LED light", "Anti-static technology"],
                    grinderType: "Conical burr"
                ),
                category: "Mid-Range",
                averageRating: 4.5,
                ratingCount: 1450,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .grinder,
                brand: "Baratza",
                model: "Sette 270",
                specifications: EquipmentSpecifications(
                    size: "5.0\" x 6.2\" x 13.5\"",
                    capacity: "10oz bean hopper",
                    features: ["40mm conical burrs", "270 grind settings", "Macro/micro adjustments", "Programmable dosing", "Grounds bin"],
                    grinderType: "Conical burr"
                ),
                category: "Espresso Focused",
                averageRating: 4.4,
                ratingCount: 890,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .grinder,
                brand: "Baratza",
                model: "Vario",
                specifications: EquipmentSpecifications(
                    size: "5.1\" x 6.5\" x 15.0\"",
                    capacity: "8oz bean hopper",
                    features: ["54mm ceramic flat burrs", "230 grind settings", "Digital display", "Programmable dosing", "Portafilter hook"],
                    grinderType: "Flat burr"
                ),
                category: "Professional",
                averageRating: 4.6,
                ratingCount: 560,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .grinder,
                brand: "Baratza",
                model: "Forte BG",
                specifications: EquipmentSpecifications(
                    size: "6.3\" x 9.8\" x 16.5\"",
                    capacity: "10oz bean hopper",
                    features: ["54mm ceramic flat burrs", "260 grind settings", "All-purpose grinding", "Digital display", "Commercial motor"],
                    grinderType: "Flat burr"
                ),
                category: "Commercial",
                averageRating: 4.7,
                ratingCount: 340,
                createdBy: createdBy,
                isVerified: true
            ),
            
            // MARK: - De'Longhi Machines
            Equipment(
                type: .espressoMachine,
                brand: "De'Longhi",
                model: "Magnifica Start",
                specifications: EquipmentSpecifications(
                    size: "9.4\" x 17.0\" x 13.8\"",
                    capacity: "1.8L water tank",
                    features: ["Built-in burr grinder", "Manual milk frother", "13 grind settings", "Removable brewing unit", "Energy saving"],
                    boilerType: "Single boiler"
                ),
                category: "Entry Automatic",
                averageRating: 4.2,
                ratingCount: 780,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .espressoMachine,
                brand: "De'Longhi",
                model: "Magnifica Evo",
                specifications: EquipmentSpecifications(
                    size: "9.4\" x 17.0\" x 13.8\"",
                    capacity: "1.8L water tank",
                    features: ["Built-in burr grinder", "LatteCrema system", "Bean-to-cup", "My Menu", "SoftTouch control panel"],
                    boilerType: "Single boiler"
                ),
                category: "Automatic",
                averageRating: 4.4,
                ratingCount: 920,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .espressoMachine,
                brand: "De'Longhi",
                model: "La Specialista Arte Evo",
                specifications: EquipmentSpecifications(
                    size: "9.2\" x 13.8\" x 16.9\"",
                    capacity: "1.4L water tank",
                    features: ["Smart tamping station", "Active temperature control", "Cold brew function", "Manual milk frother", "Sensor grinding"],
                    boilerType: "Thermoblock"
                ),
                category: "Manual",
                averageRating: 4.5,
                ratingCount: 650,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .espressoMachine,
                brand: "De'Longhi",
                model: "Eletta Explore",
                specifications: EquipmentSpecifications(
                    size: "9.6\" x 17.3\" x 14.8\"",
                    capacity: "2L water tank",
                    features: ["Color touch display", "Cold brew technology", "LatteCrema system", "Bean Adapt technology", "My Menu"],
                    boilerType: "Single boiler"
                ),
                category: "Premium Automatic",
                averageRating: 4.6,
                ratingCount: 420,
                createdBy: createdBy,
                isVerified: true
            ),
            Equipment(
                type: .espressoMachine,
                brand: "De'Longhi",
                model: "PrimaDonna Elite",
                specifications: EquipmentSpecifications(
                    size: "9.4\" x 17.3\" x 15.4\"",
                    capacity: "2L water tank",
                    features: ["Color touch display", "LatteCrema system", "Bean-to-cup", "Doppio+ function", "Smart One Touch"],
                    boilerType: "Single boiler"
                ),
                category: "Elite Automatic",
                averageRating: 4.7,
                ratingCount: 280,
                createdBy: createdBy,
                isVerified: true
            )
        ]
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