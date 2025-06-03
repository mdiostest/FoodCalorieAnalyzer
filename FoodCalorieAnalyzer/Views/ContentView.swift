import SwiftUI
import CoreData

// Attempt to import PersistenceController if it's in a different module, adjust as needed
// import YourProjectName // Replace YourProjectName with your project's module name if necessary

struct ContentView: View {
    @State private var selectedTab = 0
    
    // Use an EnvironmentObject for CoreDataManager
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AnalyzeFoodView() // Use the new combined view
                .tabItem {
                    Label("Analyze", systemImage: "camera.viewfinder")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
        }
        // Pass the managedObjectContext to views that need it
        .environment(\.managedObjectContext, viewContext)
    }
}

#Preview {
    // Simplified preview to avoid PersistenceController issues
    ContentView()
} 