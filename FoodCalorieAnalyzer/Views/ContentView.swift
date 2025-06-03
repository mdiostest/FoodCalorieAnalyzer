import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SweetpadView()
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
    }
}

#Preview {
    ContentView()
} 