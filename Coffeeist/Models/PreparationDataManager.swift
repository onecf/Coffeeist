import Foundation
import SwiftUI

class PreparationDataManager: ObservableObject {
    @Published var preparations: [CoffeePreparation] = []
    
    private let saveKey = "CoffeePreparations"
    
    init() {
        loadPreparations()
    }
    
    func getLastPreparation() -> CoffeePreparation {
        return preparations.last ?? CoffeePreparation.empty
    }
    
    func addPreparation(_ preparation: CoffeePreparation) {
        preparations.append(preparation)
        savePreparations()
    }
    
    func updatePreparation(_ updatedPreparation: CoffeePreparation) {
        if let index = preparations.firstIndex(where: { $0.id == updatedPreparation.id }) {
            preparations[index] = updatedPreparation
            savePreparations()
        }
    }
    
    private func savePreparations() {
        if let encoded = try? JSONEncoder().encode(preparations) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadPreparations() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([CoffeePreparation].self, from: data) {
                preparations = decoded
                return
            }
        }
        
        preparations = []
    }
} 