import SwiftUI
import AVFoundation
import UIKit

struct AnalyzeFoodView: View {
    @StateObject private var viewModel = AnalyzeFoodViewModel()
    @State private var showingImagePicker = false
    @State private var showingAnalysis = false
    @State private var showingKeyboard = false
    @State private var isSimulator = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Display Camera Preview or Placeholder
                if let image = viewModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else if isSimulator {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Camera not available in Simulator")
                            .foregroundColor(.gray)
                        Text("Please use the photo library or manual input")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .frame(height: 400)
                } else {
                    CameraPreviewView(session: viewModel.session)
                        .frame(height: 400)
                }
                
                // Display Analysis Results (if available)
                if let analysis = viewModel.currentAnalysis {
                    FoodDetailsView(analysis: analysis)
                        .padding(.horizontal)
                }
                
                Spacer() // Pushes input field and buttons to the bottom
                
                // Manual Input Field
                TextField("Enter food name", text: $viewModel.foodNameInput, onCommit: viewModel.analyzeManualInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Buttons for Camera/Photo Library/Keyboard (always visible)
                HStack(spacing: 20) {
                    // Photo Library Button
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 30))
                    }
                    
                    // Camera Capture Button (Device Only)
                    if !isSimulator {
                        Button(action: {
                            viewModel.capturePhoto()
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                    }
                    
                    // Show Keyboard Button
                    Button(action: {
                        showingKeyboard.toggle()
                    }) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 30))
                    }
                }
                .padding()
                
                // Custom Keyboard
                if showingKeyboard {
                    CustomKeyboardView(text: $viewModel.foodNameInput, isVisible: $showingKeyboard)
                        .frame(height: 250)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: showingKeyboard)
                }
            }
            .navigationTitle("Analyze Food")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $viewModel.capturedImage)
                    .onDisappear {
                        if viewModel.capturedImage != nil {
                            Task { // Use Task for async analysis
                                await viewModel.analyzeImage()
                            }
                        }
                    }
            }
            .alert("Error", isPresented: $viewModel.showingErrorAlert) {
                Button("OK") {
                    viewModel.errorMessage = nil
                    viewModel.showingErrorAlert = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            .onAppear {
                #if targetEnvironment(simulator)
                isSimulator = true
                #endif
            }
        }
    }
}

// Re-use existing views (assuming they are defined elsewhere and included in the target)
// struct CameraPreviewView: UIViewRepresentable { ... }
// struct FoodDetailsView: View { ... }
// struct CustomKeyboardView: View { ... }
// struct ImagePicker: UIViewControllerRepresentable { ... }

#Preview {
    AnalyzeFoodView()
} 