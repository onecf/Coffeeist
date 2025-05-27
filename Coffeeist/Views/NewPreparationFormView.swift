import SwiftUI

struct NewPreparationFormView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCoffeeBean: CoffeeBean?
    @State private var selectedBrewingMethod: BrewingMethod?
    @State private var measurements = PreparationMeasurements()
    @State private var preparationRating = 5
    @State private var coffeeBeanRating = 5
    @State private var characteristics = CoffeeCharacteristics()
    @State private var notes = ""
    @State private var isPublic = true
    
    @State private var coffeeBeans: [CoffeeBean] = []
    @State private var brewingMethods: [BrewingMethod] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            // Coffee Bean Selection
            Section("Coffee Bean") {
                if let selectedCoffeeBean = selectedCoffeeBean {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(selectedCoffeeBean.brand)
                                .fontWeight(.medium)
                            Text("\(selectedCoffeeBean.origin) • \(selectedCoffeeBean.roastLevel)")
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
                    NavigationLink("Select Coffee Bean") {
                        CoffeeBeanPickerView(selectedBean: $selectedCoffeeBean, coffeeBeans: coffeeBeans)
                    }
                    .foregroundColor(.brown)
                }
            }
            
            // Brewing Method Selection
            Section("Brewing Method") {
                Picker("Method", selection: $selectedBrewingMethod) {
                    Text("Select Method").tag(nil as BrewingMethod?)
                    ForEach(brewingMethods) { method in
                        Text(method.name).tag(method as BrewingMethod?)
                    }
                }
            }
            
            // Measurements
            Section("Measurements") {
                HStack {
                    Text("Grind Size")
                    Spacer()
                    TextField("18", text: $measurements.grindSize)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .keyboardType(.decimalPad)
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
                    Task {
                        await savePreparation()
                    }
                }
                .disabled(!isFormValid || isSaving)
            }
        }
        .task {
            await loadData()
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
    
    private var isFormValid: Bool {
        selectedCoffeeBean != nil && 
        selectedBrewingMethod != nil &&
        !measurements.groundCoffeeWeight.isEmpty &&
        !measurements.yieldWeight.isEmpty
    }
    
    private func loadData() async {
        isLoading = true
        
        do {
            async let coffeeBeansTask = databaseService.getCoffeeBeans(limit: 100)
            async let brewingMethodsTask = databaseService.getBrewingMethods()
            
            self.coffeeBeans = try await coffeeBeansTask
            self.brewingMethods = try await brewingMethodsTask
            
            // Select default espresso method if available
            if let espressoMethod = brewingMethods.first(where: { $0.name.lowercased().contains("espresso") }) {
                selectedBrewingMethod = espressoMethod
            }
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func savePreparation() async {
        guard let userId = authService.currentUser?.uid,
              let coffeeBeanId = selectedCoffeeBean?.id,
              let brewingMethodId = selectedBrewingMethod?.id else {
            return
        }
        
        isSaving = true
        
        let preparation = Preparation(
            userId: userId,
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