import Foundation
import FirebaseFirestore

struct BrewingMethod: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var category: BrewingCategory
    var defaultParameters: BrewingParameters?
    var imageURL: String?
    
    init(
        name: String,
        description: String,
        category: BrewingCategory,
        defaultParameters: BrewingParameters? = nil,
        imageURL: String? = nil
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.defaultParameters = defaultParameters
        self.imageURL = imageURL
    }
}

enum BrewingCategory: String, CaseIterable, Codable {
    case espresso = "espresso"
    case pourOver = "pour_over"
    case immersion = "immersion"
    case pressure = "pressure"
    case cold = "cold"
    
    var displayName: String {
        switch self {
        case .espresso:
            return "Espresso"
        case .pourOver:
            return "Pour Over"
        case .immersion:
            return "Immersion"
        case .pressure:
            return "Pressure"
        case .cold:
            return "Cold Brew"
        }
    }
    
    var icon: String {
        switch self {
        case .espresso:
            return "cup.and.saucer.fill"
        case .pourOver:
            return "triangle.fill"
        case .immersion:
            return "cylinder.fill"
        case .pressure:
            return "capsule.fill"
        case .cold:
            return "snowflake"
        }
    }
}

struct BrewingParameters: Codable, Hashable {
    var grindSize: String?
    var waterTemp: Double?
    var brewTime: String?
    var ratio: String? // Coffee to water ratio
    var pressure: String? // For espresso
    var bloomTime: String? // For pour over
    
    init(
        grindSize: String? = nil,
        waterTemp: Double? = nil,
        brewTime: String? = nil,
        ratio: String? = nil,
        pressure: String? = nil,
        bloomTime: String? = nil
    ) {
        self.grindSize = grindSize
        self.waterTemp = waterTemp
        self.brewTime = brewTime
        self.ratio = ratio
        self.pressure = pressure
        self.bloomTime = bloomTime
    }
}

// Predefined brewing methods
extension BrewingMethod {
    static let espresso = BrewingMethod(
        name: "Espresso",
        description: "Traditional Italian coffee brewing method using pressure",
        category: .espresso,
        defaultParameters: BrewingParameters(
            grindSize: "Fine",
            waterTemp: 93.0,
            brewTime: "25-30 seconds",
            ratio: "1:2",
            pressure: "9 bars"
        )
    )
    
    static let v60 = BrewingMethod(
        name: "Hario V60",
        description: "Japanese pour-over dripper with spiral ridges",
        category: .pourOver,
        defaultParameters: BrewingParameters(
            grindSize: "Medium-fine",
            waterTemp: 96.0,
            brewTime: "2:30-3:30",
            ratio: "1:16",
            bloomTime: "30 seconds"
        )
    )
    
    static let frenchPress = BrewingMethod(
        name: "French Press",
        description: "Full immersion brewing with metal filter",
        category: .immersion,
        defaultParameters: BrewingParameters(
            grindSize: "Coarse",
            waterTemp: 96.0,
            brewTime: "4 minutes",
            ratio: "1:15"
        )
    )
    
    static let aeropress = BrewingMethod(
        name: "AeroPress",
        description: "Pressure-assisted brewing device",
        category: .pressure,
        defaultParameters: BrewingParameters(
            grindSize: "Medium-fine",
            waterTemp: 85.0,
            brewTime: "1:30-2:30",
            ratio: "1:16"
        )
    )
    
    static let chemex = BrewingMethod(
        name: "Chemex",
        description: "Pour-over with thick paper filters",
        category: .pourOver,
        defaultParameters: BrewingParameters(
            grindSize: "Medium-coarse",
            waterTemp: 96.0,
            brewTime: "4-6 minutes",
            ratio: "1:17",
            bloomTime: "45 seconds"
        )
    )
    
    static let defaultMethods: [BrewingMethod] = [
        .espresso, .v60, .frenchPress, .aeropress, .chemex
    ]
} 