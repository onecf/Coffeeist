import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var dataManager: PreparationDataManager
    @State private var selectedPreparation: CoffeePreparation?
    @State private var preparationToEdit: CoffeePreparation?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(dataManager.preparations.reversed()) { prep in
                    PreparationCard(preparation: prep)
                        .onTapGesture {
                            selectedPreparation = prep
                        }
                        .contextMenu {
                            Button {
                                preparationToEdit = prep
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                }
            }
            .padding()
        }
        .sheet(item: $selectedPreparation) { prep in
            PreparationDetailView(preparation: prep)
        }
        .sheet(item: $preparationToEdit) { prep in
            NavigationStack {
                PreparationFormView(editMode: true, preparationToEdit: prep)
            }
            .presentationDetents([.large])
        }
    }
}

struct PreparationCard: View {
    let preparation: CoffeePreparation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and coffee info
            HStack {
                VStack(alignment: .leading) {
                    Text(preparation.coffeeBrand)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        if !preparation.coffeeOrigin.isEmpty {
                            Text(preparation.coffeeOrigin)
                        }
                        
                        if !preparation.coffeeOrigin.isEmpty && !preparation.coffeeRoastLevel.isEmpty {
                            Text("•")
                        }
                        
                        if !preparation.coffeeRoastLevel.isEmpty {
                            Text(preparation.coffeeRoastLevel)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    if !preparation.espressoMachineBrand.isEmpty {
                        Text("Machine: \(preparation.espressoMachineBrand)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Text(formattedDate(preparation.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Coffee image if available
            if let image = preparation.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
            }
            
            // Stats grid
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Dose")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(preparation.groundCoffeeWeight)g")
                        .font(.headline)
                }
                
                VStack(alignment: .leading) {
                    Text("Yield")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(preparation.yieldWeight)g")
                        .font(.headline)
                }
                
                VStack(alignment: .leading) {
                    Text("Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(preparation.extractionTime)s")
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Rating")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 2) {
                        Text("\(preparation.rating)")
                            .font(.headline)
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            // Notes preview if available
            if !preparation.notes.isEmpty {
                Text(preparation.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct PreparationDetailView: View {
    let preparation: CoffeePreparation
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Coffee image if available
                    if let image = preparation.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    }
                    
                    // Coffee details
                    GroupBox("Coffee") {
                        DetailRow(label: "Brand", value: preparation.coffeeBrand)
                        DetailRow(label: "Origin", value: preparation.coffeeOrigin)
                        DetailRow(label: "Roast Level", value: preparation.coffeeRoastLevel)
                    }
                    
                    // Equipment
                    GroupBox("Equipment") {
                        if !preparation.espressoMachineBrand.isEmpty {
                            DetailRow(label: "Espresso Machine", value: "\(preparation.espressoMachineBrand) \(preparation.espressoMachineModel)")
                        }
                        
                        if !preparation.grinderBrand.isEmpty {
                            DetailRow(label: "Grinder", value: "\(preparation.grinderBrand) \(preparation.grinderModel)")
                        }
                        
                        if !preparation.portafilterType.isEmpty {
                            DetailRow(label: "Portafilter Type", value: preparation.portafilterType)
                        }
                        
                        if !preparation.portafilterSize.isEmpty {
                            DetailRow(label: "Portafilter Size", value: "\(preparation.portafilterSize) mm")
                        }
                    }
                    
                    // Preparation parameters
                    GroupBox("Parameters") {
                        DetailRow(label: "Grind Size", value: preparation.grindSize)
                        DetailRow(label: "Grinding Time", value: "\(preparation.grindingTime) sec")
                        DetailRow(label: "Ground Coffee", value: "\(preparation.groundCoffeeWeight) g")
                        DetailRow(label: "Pre-Infusion", value: "\(preparation.preInfusionTime) sec")
                        DetailRow(label: "Extraction Time", value: "\(preparation.extractionTime) sec")
                        DetailRow(label: "Yield", value: "\(preparation.yieldWeight) g")
                        DetailRow(label: "Brew Ratio", value: "1:\(String(format: "%.1f", Double(preparation.yieldWeight) ?? 0 / (Double(preparation.groundCoffeeWeight) ?? 1)))")
                    }
                    
                    // Rating
                    GroupBox("Rating & Characteristics") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Your Rating:")
                                Spacer()
                                Text("\(preparation.rating)/10")
                                    .bold()
                                ForEach(1...min(preparation.rating, 5), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            Divider()
                            
                            Text("Coffee Characteristics")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.top, 4)
                            
                            DetailRow(label: "Bitterness", value: "\(preparation.bitterness)/10")
                            DetailRow(label: "Acidity", value: "\(preparation.acidity)/10")
                            DetailRow(label: "Sweetness", value: "\(preparation.sweetness)/10")
                            DetailRow(label: "Body", value: "\(preparation.body)/10")
                            DetailRow(label: "Crema", value: "\(preparation.crema)/10")
                            DetailRow(label: "Aroma", value: "\(preparation.aroma)/10")
                            DetailRow(label: "Aftertaste", value: "\(preparation.aftertaste)/10")
                        }
                    }
                    
                    // Notes
                    if !preparation.notes.isEmpty {
                        GroupBox("Notes") {
                            Text(preparation.notes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Coffee Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button("Done") {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                NavigationStack {
                    PreparationFormView(editMode: true, preparationToEdit: preparation)
                }
                .presentationDetents([.large])
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TimelineView()
        .environmentObject(PreparationDataManager())
} 
