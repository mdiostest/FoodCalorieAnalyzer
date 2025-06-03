import SwiftUI
import AVFoundation
import Vision
import CoreData

class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var foodAnalysisRecord: FoodRecord?
    @Published var currentAnalysis: FoodAnalysis?
    @Published var isAnalyzing = false
    @Published var error: String?
    
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentPosition: AVCaptureDevice.Position = .back
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: currentPosition),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            return
        }
        
        session.addInput(videoInput)
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func switchCamera() {
        session.beginConfiguration()
        
        // Remove existing input
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
        }
        
        // Switch camera position
        currentPosition = currentPosition == .back ? .front : .back
        
        // Add new input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: currentPosition),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            return
        }
        
        session.addInput(videoInput)
        session.commitConfiguration()
    }
    
    func analyzeFood() {
        guard let image = capturedImage else {
            print("DEBUG: No image to analyze")
            return
        }
        
        print("DEBUG: Starting food analysis")
        isAnalyzing = true
        error = nil
        foodAnalysisRecord = nil
        currentAnalysis = nil
        
        // Compress image before sending to API
        guard let compressedImageData = ImageCompressor.compressImageForAPI(image) else {
            print("DEBUG: Failed to compress image")
            error = "Failed to compress image"
            isAnalyzing = false
            return
        }
        
        print("DEBUG: Image compressed successfully")
        
        Task {
            do {
                print("DEBUG: Sending request to OpenAI API")
                let analysis = try await OpenAIService.shared.analyzeFoodImage(compressedImageData)
                print("DEBUG: Received analysis from API: \(analysis)")
                
                // Save to Core Data and get the saved record
                let savedRecord = CoreDataManager.shared.createFoodRecord(from: analysis)
                savedRecord.imageData = compressedImageData
                CoreDataManager.shared.saveContext()
                print("DEBUG: Saved record to Core Data")
                
                DispatchQueue.main.async {
                    self.foodAnalysisRecord = savedRecord
                    self.currentAnalysis = analysis
                    self.isAnalyzing = false
                    print("DEBUG: Updated UI with analysis results")
                }
            } catch {
                print("DEBUG: API Error: \(error)")
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isAnalyzing = false
                }
            }
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("DEBUG: Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("DEBUG: Failed to create image from photo data")
            return
        }
        
        print("DEBUG: Photo captured successfully")
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
} 