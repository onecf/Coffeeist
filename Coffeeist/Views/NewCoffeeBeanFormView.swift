import SwiftUI

struct NewCoffeeBeanFormView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    @Environment(\.dismiss) private var dismiss
    
    let onCoffeeBeanCreated: (CoffeeBean) -> Void
    
    @State private var brand = ""
    @State private var name = ""
    @State private var origin = ""
    @State private var selectedRoastLevel: RoastLevel = .medium
    @State private var selectedProcessingMethod: ProcessingMethod?
    @State private var tastingNotesText = ""
    @State private var price = ""
    @State private var roastDate = Date()
    @State private var hasRoastDate = false
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var tastingNotes: [String] {
        tastingNotesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        Form {
            Section("Basic Information") {
                TextField("Brand", text: $brand)
                    .textInputAutocapitalization(.words)
                
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)
                
                TextField("Origin", text: $origin)
                    .textInputAutocapitalization(.words)
            }
            
            Section("Roast Details") {
                Picker("Roast Level", selection: $selectedRoastLevel) {
                    ForEach(RoastLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("Processing Method", selection: $selectedProcessingMethod) {
                    Text("Not specified").tag(nil as ProcessingMethod?)
                    ForEach(ProcessingMethod.allCases, id: \.self) { method in
                        Text(method.displayName).tag(method as ProcessingMethod?)
                    }
                }
                .pickerStyle(.menu)
                
                Toggle("Has roast date", isOn: $hasRoastDate)
                
                if hasRoastDate {
                    DatePicker("Roast Date", selection: $roastDate, displayedComponents: .date)
                }
            }
            
            Section("Tasting Notes") {
                TextField("Enter tasting notes separated by commas", text: $tastingNotesText, axis: .vertical)
                    .lineLimit(2...4)
                
                if !tastingNotes.isEmpty {
                    Text("Preview: \(tastingNotes.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Price (Optional)") {
                HStack {
                    Text("$")
                    TextField("0.00", text: $price)
                        .keyboardType(.decimalPad)
                }
            }
            
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
        .navigationTitle("Add Coffee Bean")
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
                        await saveCoffeeBean()
                    }
                }
                .disabled(!isFormValid || isSaving)
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
    }
    
    private var isFormValid: Bool {
        !brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var validationMessage: String {
        var issues: [String] = []
        
        if brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append("Brand is required")
        }
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append("Name is required")
        }
        if origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append("Origin is required")
        }
        
        if issues.isEmpty {
            return "Ready to save"
        } else {
            return "Missing: " + issues.joined(separator: ", ")
        }
    }
    
    private func saveCoffeeBean() async {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isSaving = true
        
        let priceValue = Double(price.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let coffeeBean = CoffeeBean(
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            origin: origin.trimmingCharacters(in: .whitespacesAndNewlines),
            roastLevel: selectedRoastLevel,
            processingMethod: selectedProcessingMethod,
            tastingNotes: tastingNotes,
            roastDate: hasRoastDate ? roastDate : nil,
            price: priceValue,
            createdBy: userId
        )
        
        do {
            let coffeeBeanId = try await databaseService.createCoffeeBean(coffeeBean)
            var savedCoffeeBean = coffeeBean
            savedCoffeeBean.id = coffeeBeanId
            
            onCoffeeBeanCreated(savedCoffeeBean)
            
            // Notify inventory to refresh
            print("☕ NewCoffeeBeanFormView: Coffee bean created successfully, posting notification...")
            NotificationCenter.default.post(name: .inventoryNeedsRefresh, object: nil)
            
            dismiss()
        } catch {
            errorMessage = "Failed to save coffee bean: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
}

#Preview {
    NavigationStack {
        NewCoffeeBeanFormView { _ in }
            .environmentObject(AuthenticationService())
            .environmentObject(DatabaseService())
    }
} 