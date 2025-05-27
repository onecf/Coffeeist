import SwiftUI

struct CoffeeBeanPickerView: View {
    @Binding var selectedBean: CoffeeBean?
    let coffeeBeans: [CoffeeBean]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredBeans: [CoffeeBean] {
        if searchText.isEmpty {
            return coffeeBeans
        } else {
            return coffeeBeans.filter { bean in
                bean.brand.localizedCaseInsensitiveContains(searchText) ||
                bean.name.localizedCaseInsensitiveContains(searchText) ||
                bean.origin.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredBeans) { bean in
                CoffeeBeanRow(bean: bean, isSelected: selectedBean?.id == bean.id) {
                    selectedBean = bean
                    dismiss()
                }
            }
            .searchable(text: $searchText, prompt: "Search coffee beans...")
            .navigationTitle("Select Coffee Bean")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CoffeeBeanRow: View {
    let bean: CoffeeBean
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bean.brand)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(bean.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(bean.origin)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(bean.roastLevel.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !bean.tastingNotes.isEmpty {
                        Text(bean.tastingNotes.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        if bean.averageRating > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", bean.averageRating))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("(\(bean.ratingCount))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if let price = bean.formattedPrice {
                            Text(price)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.brown)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.brown)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let sampleBeans = CoffeeBean.defaultBeans(createdBy: "user123")
    
    CoffeeBeanPickerView(
        selectedBean: .constant(nil),
        coffeeBeans: sampleBeans
    )
} 