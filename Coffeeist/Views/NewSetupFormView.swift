import SwiftUI

// Notification names for inventory updates
extension Notification.Name {
    static let setupCreated = Notification.Name("setupCreated")
    static let inventoryNeedsRefresh = Notification.Name("inventoryNeedsRefresh")
}

struct NewSetupFormView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    @Environment(\.dismiss) private var dismiss
    
    let onSetupCreated: (UserSetup) -> Void
    
    @State private var setupName = ""
    @State private var selectedBrewingMethod: BrewingMethod?
    @State private var selectedEquipment = SetupEquipment()
    @State private var isDefault = false
    @State private var isPublic = false
    
    @State private var brewingMethods: [BrewingMethod] = []
    @State private var equipment: [Equipment] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            if isLoading {
                Section {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }
            } else {
                Section("Setup Details") {
                    TextField("Setup Name", text: $setupName)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Brewing Method (Optional)", selection: $selectedBrewingMethod) {
                        Text("None").tag(nil as BrewingMethod?)
                        ForEach(brewingMethods) { method in
                            Text(method.name).tag(method as BrewingMethod?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Equipment") {
                    EquipmentSelector(
                        title: "Espresso Machine",
                        selectedEquipmentId: $selectedEquipment.espressoMachine,
                        equipment: equipment.filter { $0.type == .espressoMachine }
                    )
                    
                    EquipmentSelector(
                        title: "Grinder",
                        selectedEquipmentId: $selectedEquipment.grinder,
                        equipment: equipment.filter { $0.type == .grinder }
                    )
                    
                    EquipmentSelector(
                        title: "Scale",
                        selectedEquipmentId: $selectedEquipment.scale,
                        equipment: equipment.filter { $0.type == .scale }
                    )
                    
                    EquipmentSelector(
                        title: "Kettle",
                        selectedEquipmentId: $selectedEquipment.kettle,
                        equipment: equipment.filter { $0.type == .kettle }
                    )
                    
                    EquipmentSelector(
                        title: "Dripper",
                        selectedEquipmentId: $selectedEquipment.dripper,
                        equipment: equipment.filter { $0.type == .dripper }
                    )
                    
                    EquipmentSelector(
                        title: "Portafilter",
                        selectedEquipmentId: $selectedEquipment.portafilter,
                        equipment: equipment.filter { $0.type == .portafilter }
                    )
                }
                
                Section("Options") {
                    Toggle("Set as default setup", isOn: $isDefault)
                    Toggle("Make setup public", isOn: $isPublic)
                }
            }
        }
        .navigationTitle("New Setup")
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
                        await saveSetup()
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
        !setupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func loadData() async {
        isLoading = true
        
        do {
            async let brewingMethodsTask = databaseService.getBrewingMethods()
            async let equipmentTask = databaseService.getEquipment(limit: 100)
            
            self.brewingMethods = try await brewingMethodsTask
            self.equipment = try await equipmentTask
            
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func saveSetup() async {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "Missing required information"
            return
        }
        
        isSaving = true
        
        let setup = UserSetup(
            userId: userId,
            name: setupName.trimmingCharacters(in: .whitespacesAndNewlines),
            brewingMethodId: selectedBrewingMethod?.id,
            equipmentIds: selectedEquipment,
            isDefault: isDefault,
            isPublic: isPublic
        )
        
        do {
            let setupId = try await databaseService.createUserSetup(setup)
            var savedSetup = setup
            savedSetup.id = setupId
            
            onSetupCreated(savedSetup)
            
            // Notify inventory to refresh
            print("🔧 NewSetupFormView: Setup created successfully, posting notification...")
            NotificationCenter.default.post(name: .setupCreated, object: nil)
            
            dismiss()
        } catch {
            errorMessage = "Failed to save setup: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
}

struct EquipmentSelector: View {
    let title: String
    @Binding var selectedEquipmentId: String?
    let equipment: [Equipment]
    
    var selectedEquipment: Equipment? {
        equipment.first { $0.id == selectedEquipmentId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            if let selected = selectedEquipment {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selected.brand)
                            .font(.subheadline)
                        Text(selected.model)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        selectedEquipmentId = nil
                    }
                    .font(.caption)
                    .foregroundColor(.brown)
                }
                .padding(.vertical, 4)
            } else {
                Menu {
                    Button("None") {
                        selectedEquipmentId = nil
                    }
                    
                    ForEach(equipment) { item in
                        Button("\(item.brand) \(item.model)") {
                            selectedEquipmentId = item.id
                        }
                    }
                } label: {
                    HStack {
                        Text(equipment.isEmpty ? "No \(title.lowercased()) available" : "Select \(title)")
                            .foregroundColor(equipment.isEmpty ? .secondary : .brown)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                }
                .disabled(equipment.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewSetupFormView { _ in }
            .environmentObject(AuthenticationService())
            .environmentObject(DatabaseService())
    }
} 