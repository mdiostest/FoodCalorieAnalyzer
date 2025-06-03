import SwiftUI

struct CustomKeyboardView: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    
    let keys: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Z", "X", "C", "V", "B", "N", "M", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            handleKeyPress(key)
                        }) {
                            Text(key)
                                .font(.system(size: 20))
                                .frame(width: key == "⌫" ? 60 : 30, height: 40)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            HStack {
                Button(action: {
                    isVisible = false
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 60, height: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    text += " "
                }) {
                    Text("Space")
                        .font(.system(size: 16))
                        .frame(width: 100, height: 40)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func handleKeyPress(_ key: String) {
        if key == "⌫" {
            if !text.isEmpty {
                text.removeLast()
            }
        } else {
            text += key
        }
    }
}

struct SweetpadView: View {
    @State private var text: String = ""
    @State private var isKeyboardVisible: Bool = false
    @State private var showingAnalysis: Bool = false
    @State private var currentAnalysis: FoodAnalysis?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Food Analysis Display
                if let analysis = currentAnalysis {
                    FoodAnalysisCard(analysis: analysis)
                }
                
                // Input Field
                TextField("Enter food name", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: text) { newValue in
                        // Simulate food analysis when text changes
                        if !newValue.isEmpty {
                            simulateFoodAnalysis(for: newValue)
                        }
                    }
                
                // Custom Keyboard Button
                Button(action: {
                    isKeyboardVisible.toggle()
                }) {
                    HStack {
                        Image(systemName: "keyboard")
                        Text("Show Keyboard")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                if isKeyboardVisible {
                    CustomKeyboardView(text: $text, isVisible: $isKeyboardVisible)
                        .frame(height: 300)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: isKeyboardVisible)
                }
            }
            .navigationTitle("Food Analyzer")
            .padding()
        }
    }
    
    private func simulateFoodAnalysis(for foodName: String) {
        // Simulate API response with realistic data
        let analysis = FoodAnalysis(
            foodName: foodName,
            calories: Int.random(in: 100...500),
            protein: Double.random(in: 5...30),
            carbs: Double.random(in: 10...50),
            fat: Double.random(in: 2...20),
            ingredients: ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
        )
        currentAnalysis = analysis
    }
}

struct FoodAnalysisCard: View {
    let analysis: FoodAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(analysis.foodName)
                .font(.title2)
                .bold()
            
            HStack(spacing: 20) {
                NutrientView(value: "\(analysis.calories)", unit: "cal", icon: "flame.fill")
                NutrientView(value: String(format: "%.1f", analysis.protein), unit: "g protein", icon: "p.circle.fill")
                NutrientView(value: String(format: "%.1f", analysis.carbs), unit: "g carbs", icon: "c.circle.fill")
                NutrientView(value: String(format: "%.1f", analysis.fat), unit: "g fat", icon: "f.circle.fill")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Ingredients:")
                    .font(.headline)
                ForEach(analysis.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct NutrientView: View {
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
            Text(value)
                .font(.headline)
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

#Preview {
    SweetpadView()
} 