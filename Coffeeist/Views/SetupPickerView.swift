import SwiftUI

struct SetupPickerView: View {
    @Binding var selectedSetup: UserSetup?
    let userSetups: [UserSetup]
    let onCreateNew: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                ForEach(userSetups) { setup in
                    SetupRow(setup: setup, isSelected: selectedSetup?.id == setup.id) {
                        selectedSetup = setup
                        dismiss()
                    }
                }
            }
            
            Section {
                Button(action: {
                    onCreateNew()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brown)
                        Text("Create New Setup")
                            .foregroundColor(.brown)
                    }
                }
            }
        }
        .navigationTitle("Select Setup")
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

struct SetupRow: View {
    let setup: UserSetup
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(setup.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
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
    NavigationStack {
        SetupPickerView(
            selectedSetup: .constant(nil),
            userSetups: [],
            onCreateNew: {}
        )
    }
} 