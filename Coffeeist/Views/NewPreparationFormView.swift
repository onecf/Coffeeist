import SwiftUI

struct NewPreparationFormView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCoffeeBean: CoffeeBean?
    @State private var selectedBrewingMethod: BrewingMethod?
    @State private var selectedSetup: UserSetup?
    @State private var measurements = PreparationMeasurements()
    @State private var preparationRating = 5
    @State private var coffeeBeanRating = 5
    @State private var characteristics = CoffeeCharacteristics()
    @State private var notes = ""
    @State private var isPublic = true
    
    @State private var coffeeBeans: [CoffeeBean] = []
    @State private var brewingMethods: [BrewingMethod] = []
    @State private var userSetups: [UserSetup] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingNewSetupForm = false
    @State private var showingValidationAlert = false
    
    var body: some View {
        Form {
            if isLoading {
                Section {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading data...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }
            } else {
                // Setup Selection
                Section("Setup") {
                    if let selectedSetup = selectedSetup {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedSetup.name)
                                    .fontWeight(.medium)
                                if selectedSetup.isDefault {
                                    Text("Default Setup")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button("Change") {
                                self.selectedSetup = nil
                            }
                            .font(.caption)
                        }
                    } else {
                        if userSetups.isEmpty {
                            Button("Create Your First Setup") {
                                showingNewSetupForm = true
                            }
                            .foregroundColor(.brown)
                        } else {
                            NavigationLink("Select Setup") {
                                SetupPickerView(
                                    selectedSetup: $selectedSetup,
                                    userSetups: userSetups,
                                    onCreateNew: { showingNewSetupForm = true }
                                )
                            }
                            .foregroundColor(.brown)
                        }
                    }
                }
                
                // Coffee Bean Selection
                Section("Coffee Bean") {
                    if let selectedCoffeeBean = selectedCoffeeBean {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedCoffeeBean.brand)
                                    .fontWeight(.medium)
                                Text("\(selectedCoffeeBean.name)")
                                    .font(.subheadline)
                                Text("\(selectedCoffeeBean.origin) • \(selectedCoffeeBean.roastLevel.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Change") {
                                self.selectedCoffeeBean = nil
                            }
                            .font(.caption)
                        }
                    } else {
                        if coffeeBeans.isEmpty {
                            Text("No coffee beans available")
                                .foregroundStyle(.secondary)
                        } else {
                            NavigationLink("Select Coffee Bean") {
                                CoffeeBeanPickerView(selectedBean: $selectedCoffeeBean, coffeeBeans: coffeeBeans)
                            }
                            .foregroundColor(.brown)
                        }
                    }
                }
                
                // Brewing Method Selection
                Section("Brewing Method") {
                    if brewingMethods.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No brewing methods available")
                                .foregroundStyle(.secondary)
                            
                            Button("Load Brewing Methods") {
                                Task {
                                    await loadBrewingMethods()
                                }
                            }
                            .foregroundColor(.brown)
                        }
                    } else {
                        Picker("Method", selection: $selectedBrewingMethod) {
                            Text("Select Method").tag(nil as BrewingMethod?)
                            ForEach(brewingMethods) { method in
                                Text(method.name).tag(method as BrewingMethod?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // Measurements
                Section("Measurements") {
                    HStack {
                        Text("Grind Size")
                        Spacer()
                        TextField("Fine", text: $measurements.grindSize)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Ground Coffee Weight (g)")
                        Spacer()
                        TextField("18.0", text: $measurements.groundCoffeeWeight)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Extraction Time (s)")
                        Spacer()
                        TextField("28", text: $measurements.extractionTime)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Yield Weight (g)")
                        Spacer()
                        TextField("36.0", text: $measurements.yieldWeight)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                    }
                }
                
                // Ratings
                Section("Ratings") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preparation Rating")
                            .font(.subheadline)
                        HStack {
                            Slider(value: Binding(
                                get: { Double(preparationRating) },
                                set: { preparationRating = Int($0) }
                            ), in: 1...10, step: 1)
                            Text("\(preparationRating)")
                                .frame(width: 30)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coffee Bean Rating")
                            .font(.subheadline)
                        HStack {
                            Slider(value: Binding(
                                get: { Double(coffeeBeanRating) },
                                set: { coffeeBeanRating = Int($0) }
                            ), in: 1...10, step: 1)
                            Text("\(coffeeBeanRating)")
                                .frame(width: 30)
                        }
                    }
                }
                
                // Characteristics
                Section("Characteristics") {
                    CharacteristicSlider(name: "Bitterness", value: $characteristics.bitterness)
                    CharacteristicSlider(name: "Acidity", value: $characteristics.acidity)
                    CharacteristicSlider(name: "Sweetness", value: $characteristics.sweetness)
                    CharacteristicSlider(name: "Body", value: $characteristics.body)
                    CharacteristicSlider(name: "Crema", value: $characteristics.crema)
                    CharacteristicSlider(name: "Aroma", value: $characteristics.aroma)
                    CharacteristicSlider(name: "Aftertaste", value: $characteristics.aftertaste)
                }
                
                // Notes
                Section("Notes") {
                    TextField("Add your tasting notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Privacy
                Section("Privacy") {
                    Toggle("Make this preparation public", isOn: $isPublic)
                }
                
                // Validation Status
                Section("Form Status") {
                    HStack {
                        Image(systemName: isFormValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(isFormValid ? .green : .orange)
                        Text(validationMessage)
                            .foregroundColor(isFormValid ? .green : .primary)
                    }
                    .font(.subheadline)
                }
            }
        }
        .navigationTitle("New Preparation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    if isFormValid {
                        Task {
                            await savePreparation()
                        }
                    } else {
                        showingValidationAlert = true
                    }
                }
                .disabled(isSaving)
            }
        }
        .task {
            await loadData()
        }
        .sheet(isPresented: $showingNewSetupForm) {
            NavigationStack {
                NewSetupFormView { newSetup in
                    userSetups.append(newSetup)
                    selectedSetup = newSetup
                }
            }
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
        .alert("Cannot Save Preparation", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
    }
    
    private var isFormValid: Bool {
        selectedSetup != nil &&
        selectedCoffeeBean != nil && 
        selectedBrewingMethod != nil &&
        !measurements.groundCoffeeWeight.isEmpty &&
        !measurements.yieldWeight.isEmpty
    }
    
    private var validationMessage: String {
        var issues: [String] = []
        
        if selectedSetup == nil {
            issues.append("Setup is required")
        }
        if selectedCoffeeBean == nil {
            issues.append("Coffee bean is required")
        }
        if selectedBrewingMethod == nil {
            issues.append("Brewing method is required")
        }
        if measurements.groundCoffeeWeight.isEmpty {
            issues.append("Ground coffee weight is required")
        }
        if measurements.yieldWeight.isEmpty {
            issues.append("Yield weight is required")
        }
        
        if issues.isEmpty {
            return "Ready to save"
        } else {
            return "Missing: " + issues.joined(separator: ", ")
        }
    }
    
    private func loadData() async {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        
        do {
            print("🔄 Loading data for NewPreparationFormView...")
            
            async let coffeeBeansTask = databaseService.getCoffeeBeans(limit: 100)
            async let brewingMethodsTask = databaseService.getBrewingMethods()
            async let userSetupsTask = databaseService.getUserSetups(userId: userId)
            
            let (loadedBeans, loadedMethods, loadedSetups) = try await (coffeeBeansTask, brewingMethodsTask, userSetupsTask)
            
            self.coffeeBeans = loadedBeans
            self.brewingMethods = loadedMethods
            self.userSetups = loadedSetups
            
            print("✅ Loaded \(coffeeBeans.count) coffee beans, \(brewingMethods.count) brewing methods, \(userSetups.count) setups")
            
            // If no brewing methods found, try to seed them
            if brewingMethods.isEmpty {
                print("⚠️ No brewing methods found, attempting to seed...")
                try await databaseService.seedDefaultBrewingMethods()
                
                // Reload brewing methods after seeding
                let reloadedMethods = try await databaseService.getBrewingMethods()
                self.brewingMethods = reloadedMethods
                print("✅ After seeding: \(brewingMethods.count) brewing methods available")
            }
            
            // Select default setup if available
            if let defaultSetup = userSetups.first(where: { $0.isDefault }) {
                selectedSetup = defaultSetup
                
                // Auto-select brewing method from default setup if it has one
                if let brewingMethodId = defaultSetup.brewingMethodId,
                   let brewingMethod = brewingMethods.first(where: { $0.id == brewingMethodId }) {
                    selectedBrewingMethod = brewingMethod
                }
            } else if let firstSetup = userSetups.first {
                selectedSetup = firstSetup
                
                // Auto-select brewing method from first setup if it has one
                if let brewingMethodId = firstSetup.brewingMethodId,
                   let brewingMethod = brewingMethods.first(where: { $0.id == brewingMethodId }) {
                    selectedBrewingMethod = brewingMethod
                }
            }
            
            // If no brewing method selected yet, select default espresso method if available
            if selectedBrewingMethod == nil,
               let espressoMethod = brewingMethods.first(where: { $0.name.lowercased().contains("espresso") }) {
                selectedBrewingMethod = espressoMethod
            }
            
        } catch {
            print("❌ Error loading data: \(error)")
            
            // Check if it's an index building error
            if error.localizedDescription.contains("index is currently building") {
                errorMessage = "Database is initializing. Please wait a moment and try again."
            } else {
                errorMessage = "Failed to load data: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    private func loadBrewingMethods() async {
        do {
            print("🔄 Manually loading brewing methods...")
            
            // First try to seed them
            try await databaseService.seedDefaultBrewingMethods()
            
            // Then load them
            let loadedMethods = try await databaseService.getBrewingMethods()
            self.brewingMethods = loadedMethods
            
            print("✅ Manually loaded \(brewingMethods.count) brewing methods")
            
            // Auto-select espresso if available
            if selectedBrewingMethod == nil,
               let espressoMethod = brewingMethods.first(where: { $0.name.lowercased().contains("espresso") }) {
                selectedBrewingMethod = espressoMethod
                print("✅ Auto-selected Espresso brewing method")
            }
            
        } catch {
            print("❌ Error manually loading brewing methods: \(error)")
            errorMessage = "Failed to load brewing methods: \(error.localizedDescription)"
        }
    }
    
    private func savePreparation() async {
        guard let userId = authService.currentUser?.uid,
              let coffeeBeanId = selectedCoffeeBean?.id,
              let brewingMethodId = selectedBrewingMethod?.id else {
            errorMessage = "Missing required information"
            return
        }
        
        isSaving = true
        
        let preparation = Preparation(
            userId: userId,
            setupId: selectedSetup?.id,
            coffeeBeanId: coffeeBeanId,
            brewingMethodId: brewingMethodId,
            measurements: measurements,
            preparationRating: preparationRating,
            coffeeBeanRating: coffeeBeanRating,
            characteristics: characteristics,
            notes: notes,
            isPublic: isPublic
        )
        
        do {
            _ = try await databaseService.createPreparation(preparation)
            dismiss()
        } catch {
            errorMessage = "Failed to save preparation: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
}

struct CharacteristicSlider: View {
    let name: String
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text("\(value)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: 0...10, step: 1)
        }
    }
}

#Preview {
    NavigationStack {
        NewPreparationFormView()
            .environmentObject(AuthenticationService())
            .environmentObject(DatabaseService())
    }
} 