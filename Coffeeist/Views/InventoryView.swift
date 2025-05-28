import SwiftUI

struct InventoryView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    
    @State private var userSetups: [UserSetup] = []
    @State private var coffeeBeans: [CoffeeBean] = []
    @State private var equipment: [Equipment] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingNewSetupForm = false
    @State private var showingNewCoffeeBeanForm = false
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    Section {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading inventory...")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    }
                } else {
                    // User Setups Section
                    Section("My Setups") {
                        if userSetups.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("No setups created yet")
                                    .foregroundStyle(.secondary)
                                    .italic()
                                
                                Button(action: {
                                    showingNewSetupForm = true
                                }) {
                                    Label("Create Your First Setup", systemImage: "plus.circle.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.brown)
                                }
                            }
                        } else {
                            ForEach(userSetups) { setup in
                                SetupInventoryRow(setup: setup)
                            }
                            
                            Button(action: {
                                showingNewSetupForm = true
                            }) {
                                Label("Add New Setup", systemImage: "plus")
                                    .font(.subheadline)
                                    .foregroundColor(.brown)
                            }
                        }
                    }
                    
                    // Coffee Beans Section
                    Section("Coffee Beans") {
                        if coffeeBeans.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("No coffee beans available")
                                    .foregroundStyle(.secondary)
                                    .italic()
                                
                                Button(action: {
                                    showingNewCoffeeBeanForm = true
                                }) {
                                    Label("Add Coffee Beans", systemImage: "plus.circle.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.brown)
                                }
                            }
                        } else {
                            ForEach(coffeeBeans) { bean in
                                CoffeeBeanInventoryRow(bean: bean)
                            }
                            
                            Button(action: {
                                showingNewCoffeeBeanForm = true
                            }) {
                                Label("Add More Coffee Beans", systemImage: "plus")
                                    .font(.subheadline)
                                    .foregroundColor(.brown)
                            }
                        }
                    }
                    
                    // Equipment by Type
                    let equipmentByType = Dictionary(grouping: equipment, by: { $0.type })
                    
                    ForEach(EquipmentType.allCases, id: \.self) { type in
                        if let typeEquipment = equipmentByType[type], !typeEquipment.isEmpty {
                            Section(type.displayName) {
                                ForEach(typeEquipment) { equipment in
                                    EquipmentInventoryRow(equipment: equipment)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {
                            showingNewSetupForm = true
                        }) {
                            Label("Add Setup", systemImage: "wrench.and.screwdriver")
                        }
                        
                        Button(action: {
                            showingNewCoffeeBeanForm = true
                        }) {
                            Label("Add Coffee Bean", systemImage: "cup.and.saucer")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .refreshable {
                await loadInventory()
            }
            .task {
                await loadInventory()
            }
            .onReceive(NotificationCenter.default.publisher(for: .setupCreated)) { _ in
                print("📦 InventoryView: Received setupCreated notification, refreshing inventory...")
                Task {
                    await loadInventory()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .inventoryNeedsRefresh)) { _ in
                Task {
                    await loadInventory()
                }
            }
            .sheet(isPresented: $showingNewSetupForm) {
                NavigationStack {
                    NewSetupFormView { newSetup in
                        userSetups.append(newSetup)
                    }
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showingNewCoffeeBeanForm) {
                NavigationStack {
                    NewCoffeeBeanFormView { newBean in
                        coffeeBeans.append(newBean)
                    }
                }
                .presentationDetents([.large])
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func loadInventory() async {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        print("📦 InventoryView: Loading inventory for user \(userId)...")
        
        do {
            async let setupsTask = databaseService.getUserSetups(userId: userId)
            async let beansTask = databaseService.getCoffeeBeans(limit: 100)
            async let equipmentTask = databaseService.getEquipment(limit: 100)
            
            let (loadedSetups, loadedBeans, loadedEquipment) = try await (setupsTask, beansTask, equipmentTask)
            
            self.userSetups = loadedSetups
            self.coffeeBeans = loadedBeans
            self.equipment = loadedEquipment
            
            print("📦 InventoryView: Successfully loaded \(loadedSetups.count) setups, \(loadedBeans.count) coffee beans, \(loadedEquipment.count) equipment items")
            
        } catch {
            print("📦 InventoryView: Error loading inventory: \(error)")
            errorMessage = "Failed to load inventory: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

struct SetupInventoryRow: View {
    let setup: UserSetup
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(setup.name)
                        .font(.headline)
                    
                    if setup.isDefault {
                        Text("DEFAULT")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.brown.opacity(0.2))
                            .foregroundColor(.brown)
                            .clipShape(Capsule())
                    }
                }
                
                if setup.equipmentIds.hasAnyEquipment {
                    Text("\(setup.equipmentIds.equipmentCount) equipment items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No equipment configured")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text("Created \(setup.createdAt, style: .date)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            Image(systemName: "wrench.and.screwdriver")
                .foregroundColor(.brown)
                .font(.title2)
        }
        .padding(.vertical, 4)
    }
}

struct CoffeeBeanInventoryRow: View {
    let bean: CoffeeBean
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bean.brand)
                    .font(.headline)
                
                Text(bean.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(bean.origin)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                    
                    Text(bean.roastLevel.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                }
                
                if let price = bean.formattedPrice {
                    Text(price)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                    Text(String(format: "%.1f", bean.averageRating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.brown)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EquipmentInventoryRow: View {
    let equipment: Equipment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.brand)
                    .font(.headline)
                
                Text(equipment.model)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let category = equipment.category {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                    Text(String(format: "%.1f", equipment.averageRating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Image(systemName: equipment.type.icon)
                    .foregroundColor(.brown)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    InventoryView()
        .environmentObject(AuthenticationService())
        .environmentObject(DatabaseService())
} 