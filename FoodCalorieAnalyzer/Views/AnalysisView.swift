import SwiftUI

struct AnalysisView: View {
    let record: FoodRecord
    @ObservedObject var viewModel: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Food Name", text: .constant(record.foodName ?? ""))
                    TextField("Calories", value: .constant(Int(record.calories)), formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Nutrition")) {
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("Protein", value: .constant(record.protein), formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("Carbs", value: .constant(record.carbs), formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("Fat", value: .constant(record.fat), formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(record.ingredients as? [String] ?? [], id: \.self) { ingredient in
                        Text(ingredient)
                    }
                }
            }
            .navigationTitle("Edit Food Record")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    viewModel.updateFoodRecord(record)
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    AnalysisView(record: FoodRecord(), viewModel: HistoryViewModel())
} 
