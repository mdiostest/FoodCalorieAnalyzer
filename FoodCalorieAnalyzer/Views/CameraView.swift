import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var showingImagePicker = false
    @State private var showingAnalysis = false
    @State private var showingErrorAlert = false
    @State private var isSimulator = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = viewModel.capturedImage {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                        
                        if let analysis = viewModel.currentAnalysis {
                            FoodDetailsView(analysis: analysis)
                        }
                    }
                } else {
                    if isSimulator {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding()
                            
                            Text("Camera not available in Simulator")
                                .foregroundColor(.gray)
                            
                            Text("Please use the photo library instead")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .frame(height: 400)
                    } else {
                        CameraPreviewView(session: viewModel.session)
                            .frame(height: 400)
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 30))
                    }
                    
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
                                        .frame(width: 60, height: 60)
                                )
                        }
                        
                        Button(action: {
                            viewModel.switchCamera()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 30))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Food Analyzer")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $viewModel.capturedImage)
                    .onDisappear {
                        if viewModel.capturedImage != nil {
                            Task {
                                do {
                                    try await viewModel.analyzeFood()
                                    showingAnalysis = true
                                } catch {
                                    errorMessage = error.localizedDescription
                                    showingErrorAlert = true
                                }
                            }
                        }
                    }
            }
            .sheet(isPresented: $showingAnalysis) {
                if let record = viewModel.foodAnalysisRecord {
                    AnalysisView(record: record)
                }
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") {
                    errorMessage = nil
                    showingErrorAlert = false
                }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            .onAppear {
                #if targetEnvironment(simulator)
                isSimulator = true
                #endif
            }
        }
    }
}

struct FoodDetailsView: View {
    let analysis: FoodAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(analysis.foodName)
                .font(.title2)
                .bold()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Calories: \(analysis.calories)")
                    Text("Protein: \(String(format: "%.1f", analysis.protein))g")
                    Text("Carbs: \(String(format: "%.1f", analysis.carbs))g")
                    Text("Fat: \(String(format: "%.1f", analysis.fat))g")
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Ingredients:")
                        .font(.headline)
                    ForEach(analysis.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                    }
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CameraView()
} 