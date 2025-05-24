import SwiftUI

struct AnalysisView: View {
    let record: FoodRecord
    @State private var foodAnalysis: FoodAnalysis
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HistoryViewModel()
    
    init(record: FoodRecord) {
        self.record = record
        _foodAnalysis = State(initialValue: FoodAnalysis(
            foodName: record.foodName ?? "Unknown Food",
            calories: Int(record.calories),
            protein: record.protein,
            carbs: record.carbs,
            fat: record.fat,
            ingredients: record.ingredients as? [String] ?? []
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let imageData = record.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(10)
                        .padding()
                }
                
                EditableAnalysisView(foodAnalysis: $foodAnalysis)
            }
            .navigationTitle("Food Analysis")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                    dismiss()
                }
            )
        }
    }
    
    private func saveChanges() {
        record.foodName = foodAnalysis.foodName
        record.calories = Int32(foodAnalysis.calories)
        record.protein = foodAnalysis.protein
        record.carbs = foodAnalysis.carbs
        record.fat = foodAnalysis.fat
        record.ingredients = foodAnalysis.ingredients as NSArray
        
        viewModel.updateRecord(record)
    }
}

#Preview {
    AnalysisView(record: FoodRecord())
} 
