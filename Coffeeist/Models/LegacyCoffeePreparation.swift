import Foundation
import UIKit

// LEGACY MODEL - To be removed after migration
struct CoffeePreparation: Identifiable, Codable {
    var id = UUID()
    var date = Date()
    
    // Coffee details
    var coffeeBrand: String
    var coffeeOrigin: String
    var coffeeRoastLevel: String
    
    // Equipment
    var grinderBrand: String
    var grinderModel: String
    var espressoMachineBrand: String
    var espressoMachineModel: String
    var portafilterType: String
    var portafilterSize: String
    
    // Preparation parameters
    var grindSize: String
    var grindingTime: String
    var groundCoffeeWeight: String
    var preInfusionTime: String
    var extractionTime: String
    var yieldWeight: String
    
    // Results
    var rating: Int // Overall user rating
    var bitterness: Int // Characteristic
    var acidity: Int // Characteristic
    var sweetness: Int // Characteristic
    var body: Int // Characteristic
    var crema: Int // Characteristic
    var aroma: Int // Characteristic
    var aftertaste: Int // Characteristic
    var notes: String
    
    // Image data
    var imageData: Data?
    
    var image: UIImage? {
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    static var empty: CoffeePreparation {
        CoffeePreparation(
            coffeeBrand: "",
            coffeeOrigin: "",
            coffeeRoastLevel: "",
            grinderBrand: "",
            grinderModel: "",
            espressoMachineBrand: "",
            espressoMachineModel: "",
            portafilterType: "",
            portafilterSize: "",
            grindSize: "",
            grindingTime: "",
            groundCoffeeWeight: "",
            preInfusionTime: "",
            extractionTime: "",
            yieldWeight: "",
            rating: 0,
            bitterness: 0,
            acidity: 0,
            sweetness: 0,
            body: 0,
            crema: 0,
            aroma: 0,
            aftertaste: 0,
            notes: "",
            imageData: nil
        )
    }
} 