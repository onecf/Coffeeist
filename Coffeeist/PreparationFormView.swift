import SwiftUI
import PhotosUI

struct PreparationFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: PreparationDataManager
    
    // Edit mode properties
    var editMode: Bool = false
    var preparationToEdit: CoffeePreparation?
    
    // Coffee details
    @State private var coffeeBrand = ""
    @State private var coffeeOrigin = ""
    @State private var coffeeRoastLevel = "Medium"
    private let roastLevels = ["Light", "Medium Light", "Medium", "Medium Dark", "Dark", "French"]
    
    // Equipment
    @State private var grinderBrand = ""
    @State private var grinderModel = ""
    @State private var espressoMachineBrand = ""
    @State private var espressoMachineModel = ""
    @State private var portafilterType = "Standard Double"
    @State private var portafilterSize = 58.0 // mm
    
    // Preparation parameters
    @State private var grindSize = 20.0 // 0-40 scale
    @State private var grindingTime = 10.0 // seconds
    @State private var groundCoffeeWeight = 18.0 // grams
    @State private var preInfusionTime = 5.0 // seconds
    @State private var extractionTime = 25.0 // seconds
    @State private var yieldWeight = 36.0 // grams
    
    // Results
    @State private var rating = 5 // Overall rating
    @State private var characteristics: [String: Int] = [
        "Bitterness": 5,
        "Acidity": 5,
        "Sweetness": 5,
        "Body": 5,
        "Crema": 5,
        "Aroma": 5,
        "Aftertaste": 5
    ]
    @State private var notes = ""
    
    // Photo selection
    @State private var selectedItem: PhotosPickerItem?
    @State private var coffeeImage: UIImage?
    
    // For tracking the ID of the preparation being edited
    @State private var editingPreparationId: UUID?
    
    // Common brands for autocomplete
    private let commonCoffeeBrands = ["Starbucks", "Lavazza", "Illy", "Blue Bottle", "Counter Culture", "Intelligentsia", "Peet's"]
    private let commonGrinderBrands = ["Baratza", "Breville", "Eureka", "Fellow", "Comandante", "Timemore", "Niche"]
    private let commonEspressoMachineBrands = ["Breville", "Gaggia", "Rancilio", "La Marzocco", "Lelit", "ECM", "Rocket", "De'Longhi"]
    private let portafilterTypes = ["Standard Double", "Standard Single", "Bottomless", "Pressurized", "2-wall", "1-wall", "Triple"]
    
    @State private var showingCoffeeBrandPicker = false
    @State private var showingGrinderBrandPicker = false
    @State private var showingEspressoMachinePicker = false
    
    var body: some View {
        Form {
            // 1. PREPARATION PARAMETERS SECTION
            Section(header: Text("Preparation Parameters")) {
                // Grind Size
                HStack {
                    Text("Grind Size")
                    Spacer()
                    Text("\(String(format: "%.1f", grindSize))")
                        .foregroundStyle(.secondary)
                    Stepper("", value: $grindSize, in: 0...40, step: 0.5)
                        .labelsHidden()
                }
                
                // Grinding Time
                HStack {
                    Text("Grinding Time")
                    Spacer()
                    Text("\(String(format: "%.1f", grindingTime)) sec")
                        .foregroundStyle(.secondary)
                    Stepper("", value: $grindingTime, in: 0...60, step: 0.5)
                        .labelsHidden()
                }
                
                // Ground Coffee Weight
                HStack {
                    Text("Ground Coffee")
                    Spacer()
                    Text("\(String(format: "%.1f", groundCoffeeWeight)) g")
                        .foregroundStyle(.secondary)
                    Stepper("", value: $groundCoffeeWeight, in: 0...30, step: 0.5)
                        .labelsHidden()
                }
                
                // Pre-Infusion Time
                HStack {
                    Text("Pre-Infusion Time")
                    Spacer()
                    Text("\(String(format: "%.1f", preInfusionTime)) sec")
                        .foregroundStyle(.secondary)
                    Stepper("", value: $preInfusionTime, in: 0...30, step: 0.5)
                        .labelsHidden()
                }
                
                // Extraction Time
                HStack {
                    Text("Extraction Time")
                    Spacer()
                    Text("\(String(format: "%.1f", extractionTime)) sec")
                        .foregroundStyle(.secondary)
                    Stepper("", value: $extractionTime, in: 0...120, step: 0.5)
                        .labelsHidden()
                }
                
                // Yield Weight
                HStack {
                    Text("Yield Weight")
                    Spacer()
                    Text("\(String(format: "%.1f", yieldWeight)) g")
                        .foregroundStyle(.secondary)
                    Stepper("", value: $yieldWeight, in: 0...120, step: 0.5)
                        .labelsHidden()
                }
                
                // Brew Ratio (calculated)
                HStack {
                    Text("Brew Ratio")
                    Spacer()
                    Text("1:\(String(format: "%.1f", yieldWeight / groundCoffeeWeight))")
                        .foregroundStyle(.secondary)
                }
            }
            
            // 2. COFFEE DETAILS SECTION
            Section(header: Text("Coffee Details")) {
                // Coffee Brand with picker
                HStack {
                    TextField("Coffee Brand", text: $coffeeBrand)
                    Button(action: {
                        showingCoffeeBrandPicker = true
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .confirmationDialog("Select Coffee Brand", isPresented: $showingCoffeeBrandPicker) {
                    ForEach(commonCoffeeBrands, id: \.self) { brand in
                        Button(brand) {
                            coffeeBrand = brand
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
                
                // Coffee Origin
                TextField("Origin", text: $coffeeOrigin)
                
                // Roast Level with picker
                Picker("Roast Level", selection: $coffeeRoastLevel) {
                    ForEach(roastLevels, id: \.self) { level in
                        Text(level).tag(level)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // 3. EQUIPMENT SECTION
            Section(header: Text("Equipment")) {
                // Espresso Machine
                HStack {
                    TextField("Espresso Machine Brand", text: $espressoMachineBrand)
                    Button(action: {
                        showingEspressoMachinePicker = true
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .confirmationDialog("Select Espresso Machine Brand", isPresented: $showingEspressoMachinePicker) {
                    ForEach(commonEspressoMachineBrands, id: \.self) { brand in
                        Button(brand) {
                            espressoMachineBrand = brand
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
                
                TextField("Espresso Machine Model", text: $espressoMachineModel)
                
                // Grinder
                HStack {
                    TextField("Grinder Brand", text: $grinderBrand)
                    Button(action: {
                        showingGrinderBrandPicker = true
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .confirmationDialog("Select Grinder Brand", isPresented: $showingGrinderBrandPicker) {
                    ForEach(commonGrinderBrands, id: \.self) { brand in
                        Button(brand) {
                            grinderBrand = brand
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
                
                TextField("Grinder Model", text: $grinderModel)
                
                // Portafilter Type
                Picker("Portafilter Type", selection: $portafilterType) {
                    ForEach(portafilterTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.menu)
                
                // Portafilter Size
                HStack {
                    Text("Portafilter Size")
                    Spacer()
                    Text("\(String(format: "%.0f", portafilterSize)) mm")
                        .foregroundStyle(.secondary)
                    Stepper("", value: $portafilterSize, in: 40...70, step: 1)
                        .labelsHidden()
                }
            }
            
            // 4. PHOTO SECTION
            Section(header: Text("Photo")) {
                VStack {
                    if let coffeeImage {
                        Image(uiImage: coffeeImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(8)
                    } else {
                        ContentUnavailableView(
                            "No Photo",
                            systemImage: "photo",
                            description: Text("Add a photo of your coffee")
                        )
                        .frame(height: 200)
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label(coffeeImage == nil ? "Add Photo" : "Change Photo", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .onChange(of: selectedItem) {
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                coffeeImage = image
                            }
                        }
                    }
                    
                    if coffeeImage != nil {
                        Button(role: .destructive) {
                            coffeeImage = nil
                            selectedItem = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
            }
            
            // 5. RATING SECTION
            Section(header: Text("Rating")) {
                RatingInputView(characteristics: $characteristics, overallRating: $rating)
            }
            
            // 6. NOTES SECTION
            Section(header: Text("Notes")) {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
            
            // SAVE BUTTON - Make it more prominent in edit mode
            Section {
                Button(editMode ? "Save Changes" : "Save Preparation") {
                    if editMode {
                        updatePreparation()
                    } else {
                        savePreparation()
                    }
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.brown)
            }
        }
        .navigationTitle(editMode ? "Edit Preparation" : "New Preparation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            if !editMode {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        loadLastPreparation()
                    } label: {
                        Label("Load Last", systemImage: "arrow.clockwise")
                    }
                    .disabled(dataManager.preparations.isEmpty)
                }
            }
        }
        .onAppear {
            if let preparationToEdit = preparationToEdit {
                loadPreparationForEdit(preparationToEdit)
            }
        }
    }
    
    private func loadPreparationForEdit(_ preparation: CoffeePreparation) {
        // Set the ID for the preparation being edited
        editingPreparationId = preparation.id
        
        // Load all the values from the preparation
        coffeeBrand = preparation.coffeeBrand
        coffeeOrigin = preparation.coffeeOrigin
        coffeeRoastLevel = preparation.coffeeRoastLevel
        grinderBrand = preparation.grinderBrand
        grinderModel = preparation.grinderModel
        espressoMachineBrand = preparation.espressoMachineBrand
        espressoMachineModel = preparation.espressoMachineModel
        portafilterType = preparation.portafilterType
        
        // Convert string values to doubles for numeric fields
        if let value = Double(preparation.portafilterSize) { portafilterSize = value }
        if let value = Double(preparation.grindSize) { grindSize = value }
        if let value = Double(preparation.grindingTime) { grindingTime = value }
        if let value = Double(preparation.groundCoffeeWeight) { groundCoffeeWeight = value }
        if let value = Double(preparation.preInfusionTime) { preInfusionTime = value }
        if let value = Double(preparation.extractionTime) { extractionTime = value }
        if let value = Double(preparation.yieldWeight) { yieldWeight = value }
        
        // Load rating and characteristics
        rating = preparation.rating
        characteristics["Bitterness"] = preparation.bitterness
        characteristics["Acidity"] = preparation.acidity
        characteristics["Sweetness"] = preparation.sweetness
        characteristics["Body"] = preparation.body
        characteristics["Crema"] = preparation.crema
        characteristics["Aroma"] = preparation.aroma
        characteristics["Aftertaste"] = preparation.aftertaste
        
        notes = preparation.notes
        
        // Load image if available
        if let imageData = preparation.imageData, let image = UIImage(data: imageData) {
            coffeeImage = image
        }
    }
    
    private func loadLastPreparation() {
        let lastPrep = dataManager.getLastPreparation()
        
        // Only prefill if we have previous data
        if !dataManager.preparations.isEmpty {
            // Convert string values to appropriate types
            coffeeBrand = lastPrep.coffeeBrand
            coffeeOrigin = lastPrep.coffeeOrigin
            coffeeRoastLevel = lastPrep.coffeeRoastLevel
            espressoMachineBrand = lastPrep.espressoMachineBrand
            espressoMachineModel = lastPrep.espressoMachineModel
            grinderBrand = lastPrep.grinderBrand
            grinderModel = lastPrep.grinderModel
            portafilterType = lastPrep.portafilterType
            if let value = Double(lastPrep.portafilterSize) { portafilterSize = value }
            
            // Convert string values to doubles for numeric fields
            if let value = Double(lastPrep.grindSize) { grindSize = value }
            if let value = Double(lastPrep.grindingTime) { grindingTime = value }
            if let value = Double(lastPrep.groundCoffeeWeight) { groundCoffeeWeight = value }
            if let value = Double(lastPrep.preInfusionTime) { preInfusionTime = value }
            if let value = Double(lastPrep.extractionTime) { extractionTime = value }
            if let value = Double(lastPrep.yieldWeight) { yieldWeight = value }
            
            // Load rating and characteristics
            rating = lastPrep.rating
            characteristics["Bitterness"] = lastPrep.bitterness
            characteristics["Acidity"] = lastPrep.acidity
            characteristics["Sweetness"] = lastPrep.sweetness
            characteristics["Body"] = lastPrep.body
            characteristics["Crema"] = lastPrep.crema
            characteristics["Aroma"] = lastPrep.aroma
            characteristics["Aftertaste"] = lastPrep.aftertaste
            
            notes = lastPrep.notes
        }
    }
    
    private func savePreparation() {
        // Convert image to data for storage
        let imageData = coffeeImage?.jpegData(compressionQuality: 0.7)
        
        let newPreparation = CoffeePreparation(
            coffeeBrand: coffeeBrand,
            coffeeOrigin: coffeeOrigin,
            coffeeRoastLevel: coffeeRoastLevel,
            grinderBrand: grinderBrand,
            grinderModel: grinderModel,
            espressoMachineBrand: espressoMachineBrand,
            espressoMachineModel: espressoMachineModel,
            portafilterType: portafilterType,
            portafilterSize: String(format: "%.0f", portafilterSize),
            grindSize: String(format: "%.1f", grindSize),
            grindingTime: String(format: "%.1f", grindingTime),
            groundCoffeeWeight: String(format: "%.1f", groundCoffeeWeight),
            preInfusionTime: String(format: "%.1f", preInfusionTime),
            extractionTime: String(format: "%.1f", extractionTime),
            yieldWeight: String(format: "%.1f", yieldWeight),
            rating: rating,
            bitterness: characteristics["Bitterness", default: 5],
            acidity: characteristics["Acidity", default: 5],
            sweetness: characteristics["Sweetness", default: 5],
            body: characteristics["Body", default: 5],
            crema: characteristics["Crema", default: 5],
            aroma: characteristics["Aroma", default: 5],
            aftertaste: characteristics["Aftertaste", default: 5],
            notes: notes,
            imageData: imageData
        )
        
        dataManager.addPreparation(newPreparation)
    }
    
    private func calculateOverallRating() -> Int {
        let sum = characteristics.values.reduce(0, +)
        return Int(round(Double(sum) / Double(characteristics.count)))
    }
    
    private func updatePreparation() {
        guard let id = editingPreparationId else { return }
        
        // Convert image to data for storage
        let imageData = coffeeImage?.jpegData(compressionQuality: 0.7)
        
        let updatedPreparation = CoffeePreparation(
            id: id,
            date: preparationToEdit?.date ?? Date(), // Keep original date
            coffeeBrand: coffeeBrand,
            coffeeOrigin: coffeeOrigin,
            coffeeRoastLevel: coffeeRoastLevel,
            grinderBrand: grinderBrand,
            grinderModel: grinderModel,
            espressoMachineBrand: espressoMachineBrand,
            espressoMachineModel: espressoMachineModel,
            portafilterType: portafilterType,
            portafilterSize: String(format: "%.0f", portafilterSize),
            grindSize: String(format: "%.1f", grindSize),
            grindingTime: String(format: "%.1f", grindingTime),
            groundCoffeeWeight: String(format: "%.1f", groundCoffeeWeight),
            preInfusionTime: String(format: "%.1f", preInfusionTime),
            extractionTime: String(format: "%.1f", extractionTime),
            yieldWeight: String(format: "%.1f", yieldWeight),
            rating: calculateOverallRating(),
            bitterness: characteristics["Bitterness", default: 5],
            acidity: characteristics["Acidity", default: 5],
            sweetness: characteristics["Sweetness", default: 5],
            body: characteristics["Body", default: 5],
            crema: characteristics["Crema", default: 5],
            aroma: characteristics["Aroma", default: 5],
            aftertaste: characteristics["Aftertaste", default: 5],
            notes: notes,
            imageData: imageData
        )
        
        dataManager.updatePreparation(updatedPreparation)
    }
}

#Preview {
    NavigationStack {
        PreparationFormView()
            .environmentObject(PreparationDataManager())
    }
} 