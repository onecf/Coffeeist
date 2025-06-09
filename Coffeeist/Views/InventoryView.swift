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
    @State private var isCoffeeBeansExpanded = false
    
    // Equipment expansion states
    @State private var isEspressoMachinesExpanded = false
    @State private var isGrindersExpanded = false
    @State private var isPortafiltersExpanded = false
    @State private var isScalesExpanded = false
    @State private var isKettlesExpanded = false
    @State private var isDrippersExpanded = false
    @State private var isFrenchPressesExpanded = false
    @State private var isAeropressesExpanded = false
    @State private var isChemexesExpanded = false
    @State private var isV60sExpanded = false
    @State private var isKalitasExpanded = false
    @State private var isOtherEquipmentExpanded = false
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    loadingSection
                } else {
                    userSetupsSection
                    coffeeBeansSection
                    equipmentSections
                }
            }
            .navigationTitle("Inventory")
            .toolbar { toolbarContent }
            .refreshable { await loadInventory() }
            .task { await loadInventory() }
            .onReceive(NotificationCenter.default.publisher(for: .setupCreated)) { _ in
                print("📦 InventoryView: Received setupCreated notification, refreshing inventory...")
                Task { await loadInventory() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .inventoryNeedsRefresh)) { _ in
                Task { await loadInventory() }
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
                Button("OK") { errorMessage = nil }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var loadingSection: some View {
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
    }
    
    private var userSetupsSection: some View {
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
    }
    
    private var coffeeBeansSection: some View {
        Section {
            CoffeeBeansDropdown(
                coffeeBeans: coffeeBeans,
                isExpanded: $isCoffeeBeansExpanded,
                onAddNewBean: { showingNewCoffeeBeanForm = true }
            )
        } header: {
            HStack {
                Text("Coffee Beans")
                Spacer()
                if !coffeeBeans.isEmpty {
                    Text("\(coffeeBeans.count)")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
    }
    
    private var equipmentSections: some View {
        ForEach(EquipmentType.allCases, id: \.self) { type in
            let typeEquipment = equipmentByType[type] ?? []
            if !typeEquipment.isEmpty {
                Section {
                    EquipmentDropdown(
                        equipmentType: type,
                        equipment: typeEquipment,
                        isExpanded: bindingFor(type)
                    )
                } header: {
                    HStack {
                        Text(type.displayName)
                        Spacer()
                        Text("\(typeEquipment.count)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
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
    
    // Helper computed properties
    private var equipmentByType: [EquipmentType: [Equipment]] {
        Dictionary(grouping: equipment, by: { $0.type })
    }
    
    // Helper function to get binding for each equipment type
    private func bindingFor(_ type: EquipmentType) -> Binding<Bool> {
        switch type {
        case .espressoMachine: $isEspressoMachinesExpanded
        case .grinder: $isGrindersExpanded
        case .portafilter: $isPortafiltersExpanded
        case .scale: $isScalesExpanded
        case .kettle: $isKettlesExpanded
        case .dripper: $isDrippersExpanded
        case .frenchPress: $isFrenchPressesExpanded
        case .aeropress: $isAeropressesExpanded
        case .chemex: $isChemexesExpanded
        case .v60: $isV60sExpanded
        case .kalita: $isKalitasExpanded
        case .other: $isOtherEquipmentExpanded
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
            async let beansTask = databaseService.getUsedCoffeeBeans(userId: userId)
            async let equipmentTask = databaseService.getUsedEquipment(userId: userId)
            
            let (loadedSetups, loadedBeans, loadedEquipment) = try await (setupsTask, beansTask, equipmentTask)
            
            self.userSetups = loadedSetups
            self.coffeeBeans = loadedBeans
            self.equipment = loadedEquipment
            
            print("📦 InventoryView: Successfully loaded \(loadedSetups.count) setups, \(loadedBeans.count) used coffee beans, \(loadedEquipment.count) used equipment items")
            
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

struct CoffeeBeansDropdown: View {
    let coffeeBeans: [CoffeeBean]
    @Binding var isExpanded: Bool
    let onAddNewBean: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Summary row
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(.brown)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if coffeeBeans.isEmpty {
                            Text("No coffee beans used yet")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text("Start making preparations to see beans here")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Used \(coffeeBeans.count) different coffee beans")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text("Tap to view all beans from your preparations")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                VStack(spacing: 8) {
                    if coffeeBeans.isEmpty {
                        VStack(spacing: 12) {
                            Text("Your inventory will show coffee beans once you start logging preparations.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: onAddNewBean) {
                                Label("Add New Coffee Bean", systemImage: "plus.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.brown)
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        ForEach(coffeeBeans) { bean in
                            CompactCoffeeBeanRow(bean: bean)
                        }
                        
                        Button(action: onAddNewBean) {
                            Label("Add More Coffee Beans", systemImage: "plus")
                                .font(.subheadline)
                                .foregroundColor(.brown)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct CompactCoffeeBeanRow: View {
    let bean: CoffeeBean
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(bean.brand) \(bean.name)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
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
                
                if let price = bean.formattedPrice {
                    Text(price)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct EquipmentDropdown: View {
    let equipmentType: EquipmentType
    let equipment: [Equipment]
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Summary row
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: equipmentType.icon)
                        .foregroundColor(.brown)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if equipment.isEmpty {
                            Text("No \(equipmentType.displayName.lowercased()) in inventory")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text("Browse equipment to add to your setup")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(equipment.count) \(equipmentType.displayName.lowercased())\(equipment.count == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text("Tap to view all your \(equipmentType.displayName.lowercased()) items")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                VStack(spacing: 8) {
                    if equipment.isEmpty {
                        VStack(spacing: 12) {
                            Text("No \(equipmentType.displayName.lowercased()) items in your inventory yet.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 8)
                    } else {
                        ForEach(equipment) { item in
                            CompactEquipmentRow(equipment: item)
                        }
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct CompactEquipmentRow: View {
    let equipment: Equipment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(equipment.brand) \(equipment.model)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
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
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

#Preview {
    InventoryView()
        .environmentObject(AuthenticationService())
        .environmentObject(DatabaseService())
} 