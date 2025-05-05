import Foundation
import UIKit

struct CoffeePreparation: Identifiable, Codable {
    var documentID: String?
    var id: UUID?
    var date: Date
    
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
    var rating: Int
    var bitterness: Int
    var acidity: Int
    var sweetness: Int
    var body: Int
    var crema: Int
    var aroma: Int
    var aftertaste: Int
    var notes: String
    var imageData: Data?
    var imageURL: String?
    
    // For Firestore
    var createdBy: String?
    
    // Computed property for display
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Computed property for image
    var image: UIImage? {
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    // Empty preparation for new entries
    static var empty: CoffeePreparation {
        CoffeePreparation(
            id: nil,
            date: Date(),
            coffeeBrand: "",
            coffeeOrigin: "",
            coffeeRoastLevel: "Medium",
            grinderBrand: "",
            grinderModel: "",
            espressoMachineBrand: "",
            espressoMachineModel: "",
            portafilterType: "Standard Double",
            portafilterSize: "58",
            grindSize: "20.0",
            grindingTime: "10.0",
            groundCoffeeWeight: "18.0",
            preInfusionTime: "5.0",
            extractionTime: "25.0",
            yieldWeight: "36.0",
            rating: 5,
            bitterness: 5,
            acidity: 5,
            sweetness: 5,
            body: 5,
            crema: 5,
            aroma: 5,
            aftertaste: 5,
            notes: "",
            imageData: nil,
            imageURL: nil
        )
    }
} 