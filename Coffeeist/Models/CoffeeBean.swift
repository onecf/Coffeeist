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
            // MARK: - Specialty Coffee Roasters
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
            ),
            
            // MARK: - Starbucks Whole Bean Coffees
            CoffeeBean(
                brand: "Starbucks",
                name: "Pike Place Roast",
                origin: "Latin America",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Smooth", "Balanced", "Rich"],
                price: 12.95,
                averageRating: 4.1,
                ratingCount: 1250,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "House Blend",
                origin: "Latin America",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Lively", "Balanced", "Nutty"],
                price: 12.95,
                averageRating: 4.0,
                ratingCount: 980,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Breakfast Blend",
                origin: "Latin America",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Bright", "Tangy", "Crisp"],
                price: 12.95,
                averageRating: 4.2,
                ratingCount: 756,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Veranda Blend",
                origin: "Latin America",
                roastLevel: .light,
                processingMethod: .washed,
                tastingNotes: ["Mellow", "Soft", "Approachable"],
                price: 12.95,
                averageRating: 3.9,
                ratingCount: 634,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "French Roast",
                origin: "Multi-region",
                roastLevel: .dark,
                processingMethod: .washed,
                tastingNotes: ["Intense", "Smoky", "Bold"],
                price: 12.95,
                averageRating: 4.3,
                ratingCount: 1120,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Italian Roast",
                origin: "Multi-region",
                roastLevel: .dark,
                processingMethod: .washed,
                tastingNotes: ["Rich", "Deep", "Caramelized"],
                price: 12.95,
                averageRating: 4.1,
                ratingCount: 892,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Espresso Roast",
                origin: "Multi-region",
                roastLevel: .dark,
                processingMethod: .washed,
                tastingNotes: ["Rich", "Caramelly", "Sweet"],
                price: 12.95,
                averageRating: 4.4,
                ratingCount: 1456,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Sumatra",
                origin: "Indonesia",
                roastLevel: .dark,
                processingMethod: .natural,
                tastingNotes: ["Earthy", "Herbal", "Full-bodied"],
                price: 13.95,
                averageRating: 4.2,
                ratingCount: 567,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Guatemala Antigua",
                origin: "Guatemala",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Spicy", "Smoky", "Full-bodied"],
                price: 13.95,
                averageRating: 4.3,
                ratingCount: 423,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Kenya",
                origin: "Kenya",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Wine-like", "Black currant", "Bright"],
                price: 13.95,
                averageRating: 4.5,
                ratingCount: 345,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Ethiopia",
                origin: "Ethiopia",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Bright", "Floral", "Citrusy"],
                price: 13.95,
                averageRating: 4.4,
                ratingCount: 289,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Colombia",
                origin: "Colombia",
                roastLevel: .medium,
                processingMethod: .washed,
                tastingNotes: ["Balanced", "Nutty", "Cocoa"],
                price: 13.95,
                averageRating: 4.2,
                ratingCount: 512,
                createdBy: createdBy,
                isVerified: true
            ),
            CoffeeBean(
                brand: "Starbucks",
                name: "Blonde Espresso Roast",
                origin: "Latin America & East Africa",
                roastLevel: .light,
                processingMethod: .washed,
                tastingNotes: ["Sweet", "Smooth", "Balanced"],
                price: 12.95,
                averageRating: 4.0,
                ratingCount: 678,
                createdBy: createdBy,
                isVerified: true
            )
        ]
    }
} 