import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // Date selector
                DatePicker("Select Date",
                          selection: $selectedDate,
                          displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                // Daily summary
                if let records = viewModel.groupedRecords[Calendar.current.startOfDay(for: selectedDate)] {
                    DailySummaryView(records: records, viewModel: viewModel)
                } else {
                    Text("No records for this date")
                        .foregroundColor(.secondary)
                }
                
                // Food records list
                List {
                    if let records = viewModel.groupedRecords[Calendar.current.startOfDay(for: selectedDate)] {
                        ForEach(records, id: \.id) { record in
                            NavigationLink(destination: AnalysisView(record: record)) {
                                FoodRecordRow(record: record)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                viewModel.deleteRecord(records[index])
                            }
                        }
                    } else {
                        Text("No records for this date")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Food History")
        }
    }
}

struct DailySummaryView: View {
    let records: [FoodRecord]
    let viewModel: HistoryViewModel
    
    var body: some View {
        let date = Calendar.current.startOfDay(for: records.first?.timestamp ?? Date())
        let summary = viewModel.getNutritionSummary(for: date)
        
        VStack(spacing: 12) {
            Text("Daily Summary")
                .font(.headline)
            
            HStack(spacing: 20) {
                NutritionValueView(title: "Calories",
                                 value: "\(viewModel.getTotalCalories(for: date))",
                                 unit: "cal")
                
                NutritionValueView(title: "Protein",
                                 value: String(format: "%.1f", summary.protein),
                                 unit: "g")
                
                NutritionValueView(title: "Carbs",
                                 value: String(format: "%.1f", summary.carbs),
                                 unit: "g")
                
                NutritionValueView(title: "Fat",
                                 value: String(format: "%.1f", summary.fat),
                                 unit: "g")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct NutritionValueView: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct FoodRecordRow: View {
    let record: FoodRecord
    
    var body: some View {
        HStack {
            if let imageData = record.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.foodName ?? "Unknown Food")
                    .font(.headline)
                
                HStack {
                    Text("\(record.calories) cal")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(record.timestamp?.formatted(date: .omitted, time: .shortened) ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}