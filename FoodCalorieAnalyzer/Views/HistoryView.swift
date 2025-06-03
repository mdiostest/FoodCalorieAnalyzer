import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // Date Picker
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                // Food Records List
                List {
                    ForEach(viewModel.foodRecords) { record in
                        FoodRecordRow(record: record)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteFoodRecord(record)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Food History")
            .onChange(of: selectedDate) { _ in
                viewModel.fetchFoodRecords(for: selectedDate)
            }
            .onAppear {
                viewModel.fetchFoodRecords(for: selectedDate)
            }
        }
    }
}

struct FoodRecordRow: View {
    let record: FoodRecord
    
    var body: some View {
        HStack(spacing: 15) {
            // Food Image
            if let imageData = record.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Food Details
            VStack(alignment: .leading, spacing: 4) {
                Text(record.foodName ?? "Unknown Food")
                    .font(.headline)
                
                HStack {
                    Text("\(record.calories) cal")
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(record.timestamp?.formatted(date: .omitted, time: .shortened) ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Nutrients
                HStack(spacing: 12) {
                    NutrientBadge(value: String(format: "%.1f", record.protein), unit: "P")
                    NutrientBadge(value: String(format: "%.1f", record.carbs), unit: "C")
                    NutrientBadge(value: String(format: "%.1f", record.fat), unit: "F")
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct NutrientBadge: View {
    let value: String
    let unit: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .bold()
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    HistoryView()
}