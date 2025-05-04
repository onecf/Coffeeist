import SwiftUI

struct RatingInputView: View {
    @Binding var characteristics: [String: Int]
    @Binding var overallRating: Int
    
    let attributes = [
        "Bitterness": "How intense is the bitterness? (1=Low, 10=High)",
        "Acidity": "How bright or tangy is the coffee? (1=Low, 10=High)",
        "Sweetness": "How sweet is the coffee? (1=Low, 10=High)",
        "Body": "How full or heavy does it feel in the mouth? (1=Light, 10=Full)",
        "Crema": "Quality and persistence of the crema. (1=Poor, 10=Excellent)",
        "Aroma": "Intensity and pleasantness of the smell. (1=Weak, 10=Strong)",
        "Aftertaste": "Quality and length of the aftertaste. (1=Short, 10=Long)"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Overall Rating Section with Elegant Slider
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Rating")
                    .font(.headline)
                
                Text("How much did you enjoy this coffee?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Rating display
                HStack(alignment: .center) {
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("\(overallRating)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.brown)
                        
                        Text("out of 10")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                
                // Custom slider with GeometryReader to get actual container width
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.2))
                            .frame(height: 16)
                        
                        // Filled portion
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.brown.opacity(0.7), .brown]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: calculateSliderWidth(totalWidth: geometry.size.width), height: 16)
                        
                        // Tick marks
                        HStack(spacing: 0) {
                            ForEach(1...10, id: \.self) { tick in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        Rectangle()
                                            .fill(Color.white.opacity(0.5))
                                            .frame(width: 1, height: tick % 5 == 0 ? 10 : 6)
                                            .offset(y: tick % 5 == 0 ? -2 : 0)
                                    )
                            }
                        }
                        .frame(height: 16)
                        
                        // Thumb
                        Circle()
                            .fill(Color.white)
                            .shadow(radius: 2)
                            .frame(width: 28, height: 28)
                            .offset(x: calculateThumbPosition(totalWidth: geometry.size.width) - 14) // Center the thumb
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateRating(at: value.location.x, totalWidth: geometry.size.width)
                            }
                    )
                }
                .frame(height: 28) // Fixed height for the slider
                .padding(.vertical, 8)
                
                // Rating labels
                HStack {
                    ForEach(1...10, id: \.self) { rating in
                        Text("\(rating)")
                            .font(.caption2)
                            .foregroundStyle(rating == overallRating ? .brown : .secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 4)
                
                // Rating description
                Text(ratingDescription())
                    .font(.subheadline)
                    .foregroundColor(.brown)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
            
            Divider()
                .padding(.vertical, 12)
            
            // Coffee Characteristics Section
            Text("Coffee Characteristics")
                .font(.headline)
                .padding(.bottom, 8)
            
            ForEach(attributes.keys.sorted(), id: \.self) { attribute in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(attribute)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(characteristics[attribute, default: 5])")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(attributes[attribute] ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                    
                    HStack {
                        Text("1")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Slider(value: Binding(
                            get: { Double(characteristics[attribute, default: 5]) },
                            set: { characteristics[attribute] = Int($0) }
                        ), in: 1...10, step: 1)
                        .tint(.brown)
                        
                        Text("10")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // Calculate the width of the filled portion of the slider
    private func calculateSliderWidth(totalWidth: CGFloat) -> CGFloat {
        let percentage = CGFloat(overallRating) / 10.0
        return totalWidth * percentage
    }
    
    // Calculate the position of the thumb
    private func calculateThumbPosition(totalWidth: CGFloat) -> CGFloat {
        let percentage = CGFloat(overallRating - 1) / 9.0
        return totalWidth * percentage
    }
    
    // Update the rating based on drag position
    private func updateRating(at position: CGFloat, totalWidth: CGFloat) {
        let percentage = max(0, min(1, position / totalWidth))
        let newRating = 1 + Int(round(percentage * 9))
        overallRating = max(1, min(10, newRating))
    }
    
    // Get a description based on the rating
    private func ratingDescription() -> String {
        switch overallRating {
        case 1...2:
            return "Not my cup of coffee"
        case 3...4:
            return "Drinkable, but needs improvement"
        case 5...6:
            return "Decent cup of coffee"
        case 7...8:
            return "Very enjoyable brew"
        case 9...10:
            return "Exceptional! One of the best!"
        default:
            return ""
        }
    }
}

#Preview {
    Form {
        Section {
            RatingInputView(
                characteristics: .constant([
                    "Bitterness": 7,
                    "Acidity": 6,
                    "Sweetness": 8,
                    "Body": 7,
                    "Crema": 9,
                    "Aroma": 8,
                    "Aftertaste": 7
                ]),
                overallRating: .constant(10)
            )
        }
    }
} 