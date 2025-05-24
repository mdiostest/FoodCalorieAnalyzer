import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            
            SweetpadView()
                .tabItem {
                    Label("Keyboard", systemImage: "keyboard")
                }
        }
    }
}

#Preview {
    ContentView()
} 