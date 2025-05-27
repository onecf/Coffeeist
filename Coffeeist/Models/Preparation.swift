import Foundation
import FirebaseFirestore

struct Preparation: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var setupId: String? // Reference to user_setups
    var coffeeBeanId: String // Reference to coffee_beans
    var brewingMethodId: String // Reference to brewing_methods
    var date: Date
    
    // Measurements
    var measurements: PreparationMeasurements
    
    // Results & Characteristics
    var preparationRating: Int // How good was this specific preparation (1-10)
    var coffeeBeanRating: Int // How good is this coffee bean (1-10)
    var characteristics: CoffeeCharacteristics
    var notes: String
    
    // Media & Privacy
    var imageURL: String?
    var isPublic: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        userId: String,
        setupId: String? = nil,
        coffeeBeanId: String,
        brewingMethodId: String,
        date: Date = Date(),
        measurements: PreparationMeasurements,
        preparationRating: Int = 0,
        coffeeBeanRating: Int = 0,
        characteristics: CoffeeCharacteristics = CoffeeCharacteristics(),
        notes: String = "",
        imageURL: String? = nil,
        isPublic: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.userId = userId
        self.setupId = setupId
        self.coffeeBeanId = coffeeBeanId
        self.brewingMethodId = brewingMethodId
        self.date = date
        self.measurements = measurements
        self.preparationRating = preparationRating
        self.coffeeBeanRating = coffeeBeanRating
        self.characteristics = characteristics
        self.notes = notes
        self.imageURL = imageURL
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct PreparationMeasurements: Codable {
    var grindSize: String
    var grindingTime: String
    var groundCoffeeWeight: String
    var preInfusionTime: String
    var extractionTime: String
    var yieldWeight: String
    var waterTemperature: String?
    var pressure: String?
    
    init(
        grindSize: String = "",
        grindingTime: String = "",
        groundCoffeeWeight: String = "",
        preInfusionTime: String = "",
        extractionTime: String = "",
        yieldWeight: String = "",
        waterTemperature: String? = nil,
        pressure: String? = nil
    ) {
        self.grindSize = grindSize
        self.grindingTime = grindingTime
        self.groundCoffeeWeight = groundCoffeeWeight
        self.preInfusionTime = preInfusionTime
        self.extractionTime = extractionTime
        self.yieldWeight = yieldWeight
        self.waterTemperature = waterTemperature
        self.pressure = pressure
    }
}

struct CoffeeCharacteristics: Codable {
    var bitterness: Int
    var acidity: Int
    var sweetness: Int
    var body: Int
    var crema: Int
    var aroma: Int
    var aftertaste: Int
    
    init(
        bitterness: Int = 0,
        acidity: Int = 0,
        sweetness: Int = 0,
        body: Int = 0,
        crema: Int = 0,
        aroma: Int = 0,
        aftertaste: Int = 0
    ) {
        self.bitterness = bitterness
        self.acidity = acidity
        self.sweetness = sweetness
        self.body = body
        self.crema = crema
        self.aroma = aroma
        self.aftertaste = aftertaste
    }
    
    var averageScore: Double {
        let total = bitterness + acidity + sweetness + body + crema + aroma + aftertaste
        return Double(total) / 7.0
    }
} 