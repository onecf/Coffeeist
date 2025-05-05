import Foundation

class MockDatabaseService: DatabaseService {
    // Sample data for previews
    private var preparations: [CoffeePreparation] = [
        CoffeePreparation(
            id: UUID(),
            date: Date(),
            coffeeBrand: "Sample Coffee",
            coffeeOrigin: "Ethiopia",
            coffeeRoastLevel: "Medium",
            grinderBrand: "Baratza",
            grinderModel: "Encore",
            espressoMachineBrand: "Breville",
            espressoMachineModel: "Barista Express",
            portafilterType: "Standard Double",
            portafilterSize: "58",
            grindSize: "18.0",
            grindingTime: "12.5",
            groundCoffeeWeight: "18.0",
            preInfusionTime: "5.0",
            extractionTime: "28.0",
            yieldWeight: "36.0",
            rating: 8,
            bitterness: 6,
            acidity: 7,
            sweetness: 8,
            body: 7,
            crema: 8,
            aroma: 9,
            aftertaste: 8,
            notes: "Fruity with chocolate notes",
            imageData: nil
        ),
        CoffeePreparation(
            id: UUID(),
            date: Date().addingTimeInterval(-86400),
            coffeeBrand: "Another Coffee",
            coffeeOrigin: "Colombia",
            coffeeRoastLevel: "Dark",
            grinderBrand: "Eureka",
            grinderModel: "Mignon",
            espressoMachineBrand: "Rancilio",
            espressoMachineModel: "Silvia",
            portafilterType: "Standard Double",
            portafilterSize: "58",
            grindSize: "15.0",
            grindingTime: "10.0",
            groundCoffeeWeight: "18.0",
            preInfusionTime: "3.0",
            extractionTime: "25.0",
            yieldWeight: "36.0",
            rating: 7,
            bitterness: 8,
            acidity: 5,
            sweetness: 6,
            body: 9,
            crema: 7,
            aroma: 7,
            aftertaste: 8,
            notes: "Rich and bold with caramel finish",
            imageData: nil
        )
    ]
    
    // Equipment suggestions for previews
    private let equipmentSuggestions: [String: [String]] = [
        "grinder": ["Baratza Encore", "Baratza Virtuoso", "Eureka Mignon", "Niche Zero", "Comandante C40"],
        "espressoMachine": ["Breville Barista Express", "Breville Dual Boiler", "Rancilio Silvia", "Gaggia Classic Pro", "La Marzocco Linea Mini"],
        "portafilter": ["Standard Double", "Standard Single", "Bottomless", "Pressurized", "Commercial"]
    ]
    
    func getPreparations(completion: @escaping ([CoffeePreparation]) -> Void) {
        completion(preparations)
    }
    
    func addPreparation(_ preparation: CoffeePreparation, completion: @escaping (Result<Void, Error>) -> Void) {
        var newPreparation = preparation
        if newPreparation.id == nil {
            newPreparation.id = UUID()
        }
        preparations.append(newPreparation)
        completion(.success(()))
    }
    
    func updatePreparation(_ preparation: CoffeePreparation, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = preparation.id, let index = preparations.firstIndex(where: { $0.id == id }) else {
            completion(.failure(NSError(domain: "MockService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Preparation not found"])))
            return
        }
        
        preparations[index] = preparation
        completion(.success(()))
    }
    
    func deletePreparation(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        preparations.removeAll { $0.id == id }
        completion(.success(()))
    }
    
    func getEquipmentSuggestions(type: String, prefix: String, completion: @escaping ([String]) -> Void) {
        guard !prefix.isEmpty else {
            completion([])
            return
        }
        
        let prefixLowercase = prefix.lowercased()
        let suggestions = equipmentSuggestions[type] ?? []
        
        let filteredSuggestions = suggestions.filter { 
            $0.lowercased().hasPrefix(prefixLowercase) 
        }
        
        completion(filteredSuggestions)
    }
} 