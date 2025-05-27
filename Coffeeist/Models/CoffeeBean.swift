import Foundation
import FirebaseFirestore

struct CoffeeBean: Identifiable, Codable {
    @DocumentID var id: String?
    var brand: String
    var name: String
    var origin: String
    var roastLevel: RoastLevel
    var processingMethod: ProcessingMethod?
    var tastingNotes: [String]
    var roastDate: Date?
    var price: Double?
    var imageURL: String?
    var averageRating: Double
    var ratingCount: Int
    var createdBy: String
    var createdAt: Date
    var isVerified: Bool
    
    init(
        brand: String,
        name: String,
        origin: String,
        roastLevel: RoastLevel,
        processingMethod: ProcessingMethod? = nil,
        tastingNotes: [String] = [],
        roastDate: Date? = nil,
        price: Double? = nil,
        imageURL: String? = nil,
        averageRating: Double = 0.0,
        ratingCount: Int = 0,
        createdBy: String,
        createdAt: Date = Date(),
        isVerified: Bool = false
    ) {
        self.brand = brand
        self.name = name
        self.origin = origin
        self.roastLevel = roastLevel
        self.processingMethod = processingMethod
        self.tastingNotes = tastingNotes
        self.roastDate = roastDate
        self.price = price
        self.imageURL = imageURL
        self.averageRating = averageRating
        self.ratingCount = ratingCount
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.isVerified = isVerified
    }
    
    var displayName: String {
        return "\(brand) \(name)"
    }
    
    var formattedPrice: String? {
        guard let price = price else { return nil }
        return String(format: "$%.2f", price)
    }
}

enum RoastLevel: String, CaseIterable, Codable {
    case light = "light"
    case mediumLight = "medium_light"
    case medium = "medium"
    case mediumDark = "medium_dark"
    case dark = "dark"
    case french = "french"
    
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .mediumLight:
            return "Medium Light"
        case .medium:
            return "Medium"
        case .mediumDark:
            return "Medium Dark"
        case .dark:
            return "Dark"
        case .french:
            return "French"
        }
    }
}

enum ProcessingMethod: String, CaseIterable, Codable {
    case washed = "washed"
    case natural = "natural"
    case honey = "honey"
    case pulpedNatural = "pulped_natural"
    case anaerobic = "anaerobic"
    case carbonic = "carbonic"
    
    var displayName: String {
        switch self {
        case .washed:
            return "Washed"
        case .natural:
            return "Natural"
        case .honey:
            return "Honey"
        case .pulpedNatural:
            return "Pulped Natural"
        case .anaerobic:
            return "Anaerobic"
        case .carbonic:
            return "Carbonic"
        }
    }
}

// Default coffee beans for seeding
extension CoffeeBean {
    static func defaultBeans(createdBy: String) -> [CoffeeBean] {
        return [
            CoffeeBean(
                brand: "Blue Bottle",
                name: "Giant Steps",
                origin: "Ethiopia",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Chocolate", "Citrus", "Floral"],
                price: 18.00,
                averageRating: 4.5,
                ratingCount: 127,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Intelligentsia",
                name: "Black Cat Classic",
                origin: "Blend",
                roastLevel: .dark,
                processingMethod: .washed,
                tastingNotes: ["Dark Chocolate", "Caramel", "Smoky"],
                price: 16.50,
                averageRating: 4.3,
                ratingCount: 89,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Counter Culture",
                name: "Hologram",
                origin: "Colombia",
                roastLevel: .light,
                processingMethod: .washed,
                tastingNotes: ["Bright", "Citrus", "Clean"],
                price: 17.00,
                averageRating: 4.6,
                ratingCount: 156,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Stumptown",
                name: "Hair Bender",
                origin: "Blend",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Balanced", "Chocolate", "Citrus"],
                price: 15.00,
                averageRating: 4.4,
                ratingCount: 203,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Onyx Coffee Lab",
                name: "Geometry",
                origin: "Guatemala",
                roastLevel: .mediumLight,
                processingMethod: .honey,
                tastingNotes: ["Honey", "Apple", "Cinnamon"],
                price: 19.50,
                averageRating: 4.7,
                ratingCount: 78,
                createdBy: createdBy,
                isVerified: true
            )
        ]
    }
} 