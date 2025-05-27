import SwiftUI

struct PreparationTimelineView: View {
    let preparations: [Preparation]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(preparations) { preparation in
                    PreparationTimelineCard(preparation: preparation)
                }
            }
            .padding()
        }
    }
}

struct PreparationTimelineCard: View {
    let preparation: Preparation
    @EnvironmentObject private var databaseService: DatabaseService
    @State private var coffeeBean: CoffeeBean?
    @State private var brewingMethod: BrewingMethod?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and rating
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preparation.date, style: .date)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(preparation.date, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < preparation.preparationRating / 2 ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    
                    Text("\(preparation.preparationRating)/10")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Coffee and brewing method info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let coffeeBean = coffeeBean {
                        Text(coffeeBean.brand)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(coffeeBean.origin) • \(coffeeBean.roastLevel)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if let brewingMethod = brewingMethod {
                    Text(brewingMethod.name)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brown.opacity(0.1))
                        .foregroundColor(.brown)
                        .cornerRadius(8)
                }
            }
            
            // Key measurements
            HStack(spacing: 16) {
                MeasurementPill(
                    label: "Dose",
                    value: preparation.measurements.groundCoffeeWeight,
                    unit: "g"
                )
                
                MeasurementPill(
                    label: "Yield",
                    value: preparation.measurements.yieldWeight,
                    unit: "g"
                )
                
                MeasurementPill(
                    label: "Time",
                    value: preparation.measurements.extractionTime,
                    unit: "s"
                )
                
                Spacer()
            }
            
            // Notes (if any)
            if !preparation.notes.isEmpty {
                Text(preparation.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            // Characteristics preview
            CharacteristicsPreview(characteristics: preparation.characteristics)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .task {
            await loadRelatedData()
        }
    }
    
    private func loadRelatedData() async {
        do {
            async let coffeeTask = databaseService.getCoffeeBean(id: preparation.coffeeBeanId)
            async let brewingTask = databaseService.getBrewingMethod(id: preparation.brewingMethodId)
            
            self.coffeeBean = try await coffeeTask
            self.brewingMethod = try await brewingTask
        } catch {
            print("Error loading related data: \(error)")
        }
    }
}

struct MeasurementPill: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 1) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

struct CharacteristicsPreview: View {
    let characteristics: CoffeeCharacteristics
    
    var body: some View {
        HStack(spacing: 8) {
            CharacteristicDot(name: "Bitter", value: characteristics.bitterness)
            CharacteristicDot(name: "Acid", value: characteristics.acidity)
            CharacteristicDot(name: "Sweet", value: characteristics.sweetness)
            CharacteristicDot(name: "Body", value: characteristics.body)
            
            Spacer()
            
            Text("Avg: \(characteristics.averageScore, specifier: "%.1f")")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct CharacteristicDot: View {
    let name: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(colorForValue(value))
                .frame(width: 8, height: 8)
            
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    private func colorForValue(_ value: Int) -> Color {
        switch value {
        case 0...3: return .red
        case 4...6: return .orange
        case 7...8: return .yellow
        case 9...10: return .green
        default: return .gray
        }
    }
}

#Preview {
    let samplePreparation = Preparation(
        userId: "user123",
        coffeeBeanId: "bean123",
        brewingMethodId: "method123",
        measurements: PreparationMeasurements(
            grindSize: "18",
            grindingTime: "12",
            groundCoffeeWeight: "18.0",
            preInfusionTime: "5",
            extractionTime: "28",
            yieldWeight: "36.0"
        ),
        preparationRating: 8,
        characteristics: CoffeeCharacteristics(
            bitterness: 6,
            acidity: 7,
            sweetness: 8,
            body: 7,
            crema: 8,
            aroma: 9,
            aftertaste: 8
        ),
        notes: "Great shot with chocolate notes and bright acidity"
    )
    
    PreparationTimelineView(preparations: [samplePreparation])
        .environmentObject(DatabaseService())
} 