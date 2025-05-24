import SwiftUI

struct EditableAnalysisView: View {
    @Binding var foodAnalysis: FoodAnalysis
    @State private var editedName: String
    @State private var editedCalories: String
    @State private var editedProtein: String
    @State private var editedCarbs: String
    @State private var editedFat: String
    @State private var editedIngredients: [String]
    
    init(foodAnalysis: Binding<FoodAnalysis>) {
        self._foodAnalysis = foodAnalysis
        self._editedName = State(initialValue: foodAnalysis.wrappedValue.foodName)
        self._editedCalories = State(initialValue: String(foodAnalysis.wrappedValue.calories))
        self._editedProtein = State(initialValue: String(foodAnalysis.wrappedValue.protein))
        self._editedCarbs = State(initialValue: String(foodAnalysis.wrappedValue.carbs))
        self._editedFat = State(initialValue: String(foodAnalysis.wrappedValue.fat))
        self._editedIngredients = State(initialValue: foodAnalysis.wrappedValue.ingredients)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Food Details")) {
                TextField("Food Name", text: $editedName)
                TextField("Calories", text: $editedCalories)
                    .keyboardType(.numberPad)
                TextField("Protein (g)", text: $editedProtein)
                    .keyboardType(.decimalPad)
                TextField("Carbs (g)", text: $editedCarbs)
                    .keyboardType(.decimalPad)
                TextField("Fat (g)", text: $editedFat)
                    .keyboardType(.decimalPad)
            }
            
            Section(header: Text("Ingredients")) {
                ForEach(editedIngredients.indices, id: \.self) { index in
                    TextField("Ingredient \(index + 1)", text: $editedIngredients[index])
                }
                
                Button(action: {
                    editedIngredients.append("")
                }) {
                    Label("Add Ingredient", systemImage: "plus")
                }
            }
            
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Edit Analysis")
    }
    
    private func saveChanges() {
        foodAnalysis = FoodAnalysis(
            foodName: editedName,
            calories: Int(editedCalories) ?? 0,
            protein: Double(editedProtein) ?? 0.0,
            carbs: Double(editedCarbs) ?? 0.0,
            fat: Double(editedFat) ?? 0.0,
            ingredients: editedIngredients.filter { !$0.isEmpty }
        )
    }
}

#Preview {
    EditableAnalysisView(foodAnalysis: .constant(
        FoodAnalysis(
            foodName: "Sample Food",
            calories: 300,
            protein: 20.0,
            carbs: 30.0,
            fat: 10.0,
            ingredients: ["Ingredient 1", "Ingredient 2"]
        )
    ))
} 