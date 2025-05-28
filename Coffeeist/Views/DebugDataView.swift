import SwiftUI

struct DebugDataView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    
    @State private var coffeeBeans: [CoffeeBean] = []
    @State private var brewingMethods: [BrewingMethod] = []
    @State private var equipment: [Equipment] = []
    @State private var userSetups: [UserSetup] = []
    
    @State private var isLoading = false
    @State private var statusMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Data Status") {
                    HStack {
                        Text("Coffee Beans")
                        Spacer()
                        Text("\(coffeeBeans.count)")
                            .foregroundColor(coffeeBeans.isEmpty ? .red : .green)
                    }
                    
                    HStack {
                        Text("Brewing Methods")
                        Spacer()
                        Text("\(brewingMethods.count)")
                            .foregroundColor(brewingMethods.isEmpty ? .red : .green)
                    }
                    
                    HStack {
                        Text("Equipment")
                        Spacer()
                        Text("\(equipment.count)")
                            .foregroundColor(equipment.isEmpty ? .red : .green)
                    }
                    
                    HStack {
                        Text("User Setups")
                        Spacer()
                        Text("\(userSetups.count)")
                            .foregroundColor(userSetups.isEmpty ? .red : .green)
                    }
                }
                
                Section("Actions") {
                    Button("Refresh Data") {
                        Task { await loadData() }
                    }
                    .disabled(isLoading)
                    
                    Button("Force Seed All Data") {
                        Task { await forceSeedData() }
                    }
                    .disabled(isLoading)
                    .foregroundColor(.orange)
                    
                    Button("Normal Seed (if empty)") {
                        Task { await normalSeedData() }
                    }
                    .disabled(isLoading)
                    .foregroundColor(.blue)
                }
                
                if !statusMessage.isEmpty {
                    Section("Status") {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if isLoading {
                    Section {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                        }
                    }
                }
            }
            .navigationTitle("Debug Data")
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        guard let userId = authService.currentUser?.uid else {
            statusMessage = "No authenticated user"
            return
        }
        
        isLoading = true
        statusMessage = "Loading data..."
        
        do {
            async let coffeeBeansTask = databaseService.getCoffeeBeans(limit: 100)
            async let brewingMethodsTask = databaseService.getBrewingMethods()
            async let equipmentTask = databaseService.getEquipment(limit: 100)
            async let userSetupsTask = databaseService.getUserSetups(userId: userId)
            
            let (loadedBeans, loadedMethods, loadedEquipment, loadedSetups) = try await (
                coffeeBeansTask, brewingMethodsTask, equipmentTask, userSetupsTask
            )
            
            self.coffeeBeans = loadedBeans
            self.brewingMethods = loadedMethods
            self.equipment = loadedEquipment
            self.userSetups = loadedSetups
            
            statusMessage = "✅ Data loaded successfully"
            
        } catch {
            statusMessage = "❌ Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func forceSeedData() async {
        guard let userId = authService.currentUser?.uid else {
            statusMessage = "No authenticated user"
            return
        }
        
        isLoading = true
        statusMessage = "Force seeding all data..."
        
        do {
            try await databaseService.forceSeedAllData(createdBy: userId)
            statusMessage = "✅ Force seeding completed"
            await loadData()
        } catch {
            statusMessage = "❌ Force seeding failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func normalSeedData() async {
        guard let userId = authService.currentUser?.uid else {
            statusMessage = "No authenticated user"
            return
        }
        
        isLoading = true
        statusMessage = "Normal seeding (if collections empty)..."
        
        do {
            try await databaseService.seedDefaultBrewingMethods()
            try await databaseService.seedDefaultCoffeeBeans(createdBy: userId)
            try await databaseService.seedDefaultEquipment(createdBy: userId)
            statusMessage = "✅ Normal seeding completed"
            await loadData()
        } catch {
            statusMessage = "❌ Normal seeding failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    DebugDataView()
        .environmentObject(AuthenticationService())
        .environmentObject(DatabaseService())
} 