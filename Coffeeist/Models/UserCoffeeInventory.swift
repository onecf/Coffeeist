import Foundation
import FirebaseFirestore

struct UserCoffeeInventory: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var coffeeBeanId: String // Reference to coffee_beans
    var purchaseDate: Date
    var quantity: Double // in grams
    var price: Double?
    var personalRating: Int? // 1-10
    var personalNotes: String?
    var isFinished: Bool
    var createdAt: Date
    
    init(
        userId: String,
        coffeeBeanId: String,
        purchaseDate: Date = Date(),
        quantity: Double,
        price: Double? = nil,
        personalRating: Int? = nil,
        personalNotes: String? = nil,
        isFinished: Bool = false,
        createdAt: Date = Date()
    ) {
        self.userId = userId
        self.coffeeBeanId = coffeeBeanId
        self.purchaseDate = purchaseDate
        self.quantity = quantity
        self.price = price
        self.personalRating = personalRating
        self.personalNotes = personalNotes
        self.isFinished = isFinished
        self.createdAt = createdAt
    }
    
    var formattedQuantity: String {
        return String(format: "%.0fg", quantity)
    }
    
    var formattedPrice: String? {
        guard let price = price else { return nil }
        return String(format: "$%.2f", price)
    }
    
    var pricePerGram: Double? {
        guard let price = price, quantity > 0 else { return nil }
        return price / quantity
    }
    
    var formattedPricePerGram: String? {
        guard let pricePerGram = pricePerGram else { return nil }
        return String(format: "$%.2f/g", pricePerGram)
    }
}

struct UserCoffeeWishlist: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var coffeeBeanId: String // Reference to coffee_beans
    var priority: Int // 1-5
    var notes: String?
    var createdAt: Date
    
    init(
        userId: String,
        coffeeBeanId: String,
        priority: Int = 3,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.userId = userId
        self.coffeeBeanId = coffeeBeanId
        self.priority = priority
        self.notes = notes
        self.createdAt = createdAt
    }
    
    var priorityText: String {
        switch priority {
        case 1:
            return "Low"
        case 2:
            return "Medium-Low"
        case 3:
            return "Medium"
        case 4:
            return "High"
        case 5:
            return "Very High"
        default:
            return "Medium"
        }
    }
    
    var priorityColor: String {
        switch priority {
        case 1, 2:
            return "gray"
        case 3:
            return "blue"
        case 4:
            return "orange"
        case 5:
            return "red"
        default:
            return "blue"
        }
    }
}

struct UserEquipmentOwned: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var equipmentId: String // Reference to equipment
    var purchaseDate: Date?
    var price: Double?
    var personalRating: Int? // 1-10
    var personalNotes: String?
    var isCurrentlyUsing: Bool
    var createdAt: Date
    
    init(
        userId: String,
        equipmentId: String,
        purchaseDate: Date? = nil,
        price: Double? = nil,
        personalRating: Int? = nil,
        personalNotes: String? = nil,
        isCurrentlyUsing: Bool = true,
        createdAt: Date = Date()
    ) {
        self.userId = userId
        self.equipmentId = equipmentId
        self.purchaseDate = purchaseDate
        self.price = price
        self.personalRating = personalRating
        self.personalNotes = personalNotes
        self.isCurrentlyUsing = isCurrentlyUsing
        self.createdAt = createdAt
    }
    
    var formattedPrice: String? {
        guard let price = price else { return nil }
        return String(format: "$%.2f", price)
    }
} 