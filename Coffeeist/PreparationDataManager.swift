import Foundation
import SwiftUI
import Combine

class PreparationDataManager: ObservableObject {
    @Published var preparations: [CoffeePreparation] = []
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    private let databaseService: DatabaseService
    
    init(databaseService: DatabaseService = FirebaseService()) {
        self.databaseService = databaseService
        loadPreparations()
    }
    
    func loadPreparations() {
        isLoading = true
        
        databaseService.getPreparations { [weak self] preparations in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.preparations = preparations
            }
        }
    }
    
    func addPreparation(_ preparation: CoffeePreparation) {
        isLoading = true
        
        databaseService.addPreparation(preparation) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.loadPreparations()
                case .failure(let error):
                    print("Error adding preparation: \(error)")
                    self?.alertItem = AlertItem.unableToAddPreparation
                }
            }
        }
    }
    
    func updatePreparation(_ preparation: CoffeePreparation) {
        isLoading = true
        
        databaseService.updatePreparation(preparation) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.loadPreparations()
                case .failure(let error):
                    print("Error updating preparation: \(error)")
                    self?.alertItem = AlertItem.unableToUpdatePreparation
                }
            }
        }
    }
    
    func deletePreparation(id: UUID) {
        isLoading = true
        
        databaseService.deletePreparation(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.loadPreparations()
                case .failure(let error):
                    print("Error deleting preparation: \(error)")
                    self?.alertItem = AlertItem.unableToDeletePreparation
                }
            }
        }
    }
    
    func getEquipmentSuggestions(type: String, prefix: String, completion: @escaping ([String]) -> Void) {
        databaseService.getEquipmentSuggestions(type: type, prefix: prefix, completion: completion)
    }
    
    func getLastPreparation() -> CoffeePreparation {
        return preparations.last ?? CoffeePreparation.empty
    }
} 