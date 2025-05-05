import Foundation
import FirebaseCore
import FirebaseFirestore

// Protocol for dependency injection and preview support
protocol DatabaseService {
    func getPreparations(completion: @escaping ([CoffeePreparation]) -> Void)
    func addPreparation(_ preparation: CoffeePreparation, completion: @escaping (Result<Void, Error>) -> Void)
    func updatePreparation(_ preparation: CoffeePreparation, completion: @escaping (Result<Void, Error>) -> Void)
    func deletePreparation(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    
    // Equipment suggestions
    func getEquipmentSuggestions(type: String, prefix: String, completion: @escaping ([String]) -> Void)
}

class FirebaseService: DatabaseService {
    private let db = Firestore.firestore()
    
    // MARK: - Preparations
    
    func getPreparations(completion: @escaping ([CoffeePreparation]) -> Void) {
        print("📊 Fetching preparations from Firestore...")
        
        db.collection("preparations")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error getting preparations: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("ℹ️ No preparation documents found")
                    completion([])
                    return
                }
                
                print("✅ Successfully fetched \(documents.count) preparations")
                
                var preparations: [CoffeePreparation] = []
                
                for document in documents {
                    let data = document.data()
                    
                    // Manual conversion from Firestore document to CoffeePreparation
                    if let dateTimestamp = data["date"] as? Timestamp,
                       let coffeeBrand = data["coffeeBrand"] as? String,
                       let coffeeOrigin = data["coffeeOrigin"] as? String,
                       let coffeeRoastLevel = data["coffeeRoastLevel"] as? String,
                       let grinderBrand = data["grinderBrand"] as? String,
                       let grinderModel = data["grinderModel"] as? String,
                       let espressoMachineBrand = data["espressoMachineBrand"] as? String,
                       let espressoMachineModel = data["espressoMachineModel"] as? String,
                       let portafilterType = data["portafilterType"] as? String,
                       let portafilterSize = data["portafilterSize"] as? String,
                       let grindSize = data["grindSize"] as? String,
                       let grindingTime = data["grindingTime"] as? String,
                       let groundCoffeeWeight = data["groundCoffeeWeight"] as? String,
                       let preInfusionTime = data["preInfusionTime"] as? String,
                       let extractionTime = data["extractionTime"] as? String,
                       let yieldWeight = data["yieldWeight"] as? String,
                       let rating = data["rating"] as? Int,
                       let bitterness = data["bitterness"] as? Int,
                       let acidity = data["acidity"] as? Int,
                       let sweetness = data["sweetness"] as? Int,
                       let body = data["body"] as? Int,
                       let crema = data["crema"] as? Int,
                       let aroma = data["aroma"] as? Int,
                       let aftertaste = data["aftertaste"] as? Int,
                       let notes = data["notes"] as? String {
                        
                        var preparation = CoffeePreparation(
                            documentID: document.documentID,
                            id: UUID(uuidString: data["id"] as? String ?? UUID().uuidString),
                            date: dateTimestamp.dateValue(),
                            coffeeBrand: coffeeBrand,
                            coffeeOrigin: coffeeOrigin,
                            coffeeRoastLevel: coffeeRoastLevel,
                            grinderBrand: grinderBrand,
                            grinderModel: grinderModel,
                            espressoMachineBrand: espressoMachineBrand,
                            espressoMachineModel: espressoMachineModel,
                            portafilterType: portafilterType,
                            portafilterSize: portafilterSize,
                            grindSize: grindSize,
                            grindingTime: grindingTime,
                            groundCoffeeWeight: groundCoffeeWeight,
                            preInfusionTime: preInfusionTime,
                            extractionTime: extractionTime,
                            yieldWeight: yieldWeight,
                            rating: rating,
                            bitterness: bitterness,
                            acidity: acidity,
                            sweetness: sweetness,
                            body: body,
                            crema: crema,
                            aroma: aroma,
                            aftertaste: aftertaste,
                            notes: notes
                        )
                        
                        // Handle image data if present
                        if let imageDataBase64 = data["imageData"] as? String,
                           let imageData = Data(base64Encoded: imageDataBase64) {
                            preparation.imageData = imageData
                        }
                        
                        // Handle image URL if present
                        if let imageURL = data["imageURL"] as? String {
                            preparation.imageURL = imageURL
                        }
                        
                        preparations.append(preparation)
                    }
                }
                
                completion(preparations)
            }
    }
    
    func addPreparation(_ preparation: CoffeePreparation, completion: @escaping (Result<Void, Error>) -> Void) {
        print("📝 Adding new preparation to Firestore...")
        
        // Create a dictionary from the preparation
        var data: [String: Any] = [
            "id": preparation.id?.uuidString ?? UUID().uuidString,
            "date": Timestamp(date: preparation.date),
            "coffeeBrand": preparation.coffeeBrand,
            "coffeeOrigin": preparation.coffeeOrigin,
            "coffeeRoastLevel": preparation.coffeeRoastLevel,
            "grinderBrand": preparation.grinderBrand,
            "grinderModel": preparation.grinderModel,
            "espressoMachineBrand": preparation.espressoMachineBrand,
            "espressoMachineModel": preparation.espressoMachineModel,
            "portafilterType": preparation.portafilterType,
            "portafilterSize": preparation.portafilterSize,
            "grindSize": preparation.grindSize,
            "grindingTime": preparation.grindingTime,
            "groundCoffeeWeight": preparation.groundCoffeeWeight,
            "preInfusionTime": preparation.preInfusionTime,
            "extractionTime": preparation.extractionTime,
            "yieldWeight": preparation.yieldWeight,
            "rating": preparation.rating,
            "bitterness": preparation.bitterness,
            "acidity": preparation.acidity,
            "sweetness": preparation.sweetness,
            "body": preparation.body,
            "crema": preparation.crema,
            "aroma": preparation.aroma,
            "aftertaste": preparation.aftertaste,
            "notes": preparation.notes
        ]
        
        // Add image data if present
        if let imageData = preparation.imageData {
            data["imageData"] = imageData.base64EncodedString()
        }
        
        // Add image URL if present
        if let imageURL = preparation.imageURL {
            data["imageURL"] = imageURL
        }
        
        // Add to Firestore
        db.collection("preparations").addDocument(data: data) { error in
            if let error = error {
                print("❌ Error adding preparation: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Successfully added preparation")
                completion(.success(()))
            }
        }
    }
    
    func updatePreparation(_ preparation: CoffeePreparation, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = preparation.id else {
            completion(.failure(NSError(domain: "FirebaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Preparation has no ID"])))
            return
        }
        
        db.collection("preparations").whereField("id", isEqualTo: id.uuidString)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "FirebaseService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Preparation not found"])))
                    return
                }
                
                // Create a dictionary from the preparation
                var data: [String: Any] = [
                    "id": preparation.id?.uuidString ?? UUID().uuidString,
                    "date": Timestamp(date: preparation.date),
                    "coffeeBrand": preparation.coffeeBrand,
                    "coffeeOrigin": preparation.coffeeOrigin,
                    "coffeeRoastLevel": preparation.coffeeRoastLevel,
                    "grinderBrand": preparation.grinderBrand,
                    "grinderModel": preparation.grinderModel,
                    "espressoMachineBrand": preparation.espressoMachineBrand,
                    "espressoMachineModel": preparation.espressoMachineModel,
                    "portafilterType": preparation.portafilterType,
                    "portafilterSize": preparation.portafilterSize,
                    "grindSize": preparation.grindSize,
                    "grindingTime": preparation.grindingTime,
                    "groundCoffeeWeight": preparation.groundCoffeeWeight,
                    "preInfusionTime": preparation.preInfusionTime,
                    "extractionTime": preparation.extractionTime,
                    "yieldWeight": preparation.yieldWeight,
                    "rating": preparation.rating,
                    "bitterness": preparation.bitterness,
                    "acidity": preparation.acidity,
                    "sweetness": preparation.sweetness,
                    "body": preparation.body,
                    "crema": preparation.crema,
                    "aroma": preparation.aroma,
                    "aftertaste": preparation.aftertaste,
                    "notes": preparation.notes
                ]
                
                // Add image data if present
                if let imageData = preparation.imageData {
                    data["imageData"] = imageData.base64EncodedString()
                }
                
                document.reference.setData(data) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    func deletePreparation(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("preparations").whereField("id", isEqualTo: id.uuidString)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "FirebaseService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Preparation not found"])))
                    return
                }
                
                document.reference.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    // MARK: - Equipment Suggestions
    
    func getEquipmentSuggestions(type: String, prefix: String, completion: @escaping ([String]) -> Void) {
        guard !prefix.isEmpty else {
            completion([])
            return
        }
        
        let prefixLowercase = prefix.lowercased()
        
        db.collection("equipment")
            .whereField("type", isEqualTo: type)
            .whereField("nameLowercase", isGreaterThanOrEqualTo: prefixLowercase)
            .whereField("nameLowercase", isLessThanOrEqualTo: prefixLowercase + "\u{f8ff}")
            .limit(to: 5)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting equipment suggestions: \(error)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let suggestions = documents.compactMap { document -> String? in
                    document.data()["name"] as? String
                }
                
                completion(suggestions)
            }
    }
} 