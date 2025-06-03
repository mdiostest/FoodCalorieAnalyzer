import SwiftUI
import AVFoundation
import CoreData
import UIKit

class AnalyzeFoodViewModel: NSObject, ObservableObject { // Inherit from NSObject
    @Published var capturedImage: UIImage? = nil
    @Published var currentAnalysis: FoodAnalysis? = nil
    @Published var foodAnalysisRecord: FoodRecord? = nil
    @Published var errorMessage: String? = nil
    @Published var showingErrorAlert = false
    
    // Add a flag to use mock analysis
    @Published var useMockAnalysis: Bool = true
    
    // Camera properties
    var session: AVCaptureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    
    // Manual input properties
    @Published var foodNameInput: String = ""
    
    private let coreDataManager = CoreDataManager.shared
    private let openAIService = OpenAIService() // Initializer should be accessible now
    private let imageCompressor = ImageCompressor()
    
    override init() { // Use override init
        super.init()
        // Setup camera session if not in simulator
        #if !targetEnvironment(simulator)
        setupCameraSession()
        #endif
    }
    
    // MARK: - Camera and Photo Library
    func setupCameraSession() {
        session.beginConfiguration()
        
        // Remove existing inputs
        for input in session.inputs {
            session.removeInput(input)
        }
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        // Add photo output
        photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput!) {
            session.addOutput(photoOutput!)
        }
        
        session.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async { // Start session on a background thread
             self.session.startRunning()
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func switchCamera() {
        session.beginConfiguration()
        guard let currentVideoInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        session.removeInput(currentVideoInput)
        
        let newPosition: AVCaptureDevice.Position = currentVideoInput.device.position == .back ? .front : .back
        
        guard let newVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }
        guard let newVideoInput = try? AVCaptureDeviceInput(device: newVideoDevice) else { return }
        
        if session.canAddInput(newVideoInput) {
            session.addInput(newVideoInput)
        }
        
        session.commitConfiguration()
    }
    
    func analyzeImage() async {
        guard let image = capturedImage else { return }
        
        if useMockAnalysis { // Check the flag
            print("Using mock analysis for image.")
            // Simulate a FoodAnalysis result
            let simulatedAnalysis = simulateFoodAnalysis(for: "Uploaded Image")
            await MainActor.run { [weak self] in
                self?.currentAnalysis = simulatedAnalysis
                // Create and save record
                if let analysisToSave = self?.currentAnalysis { // Use a temporary variable
                    self?.createAndSaveFoodRecord(from: analysisToSave)
                }
                self?.foodNameInput = "" // Clear manual input field
            }
        } else {
            // Existing API call logic
            do {
                // Compress image
                guard let compressedImageData = ImageCompressor.compressImage(image) else {
                    throw NSError(domain: "ImageCompressionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image."])
                }
                
                // Analyze image using OpenAI Vision API
                let analysis = try await openAIService.analyzeFoodImage(imageData: compressedImageData)
                
                // Update published properties
                await MainActor.run { [weak self] in
                    self?.currentAnalysis = analysis
                    // Create and save record
                    if let analysisToSave = self?.currentAnalysis { // Use a temporary variable
                        self?.createAndSaveFoodRecord(from: analysisToSave)
                    }
                    self?.foodNameInput = "" // Clear manual input field after image analysis
                }
                
            } catch {
                await MainActor.run { [weak self] in
                    self?.errorMessage = error.localizedDescription
                    self?.showingErrorAlert = true
                }
            }
        }
    }
    
    // MARK: - Manual Input
    func analyzeManualInput() {
        guard !foodNameInput.isEmpty else { return }
        
        // Clear previous image analysis results
        self.capturedImage = nil
        self.currentAnalysis = nil
        self.foodAnalysisRecord = nil
        
        // Simulate analysis for manual input
        let simulatedAnalysis = simulateFoodAnalysis(for: foodNameInput)
        self.currentAnalysis = simulatedAnalysis
        self.createAndSaveFoodRecord(from: simulatedAnalysis)
    }
    
    private func simulateFoodAnalysis(for foodName: String) -> FoodAnalysis {
        // This is a simplified simulation. In a real app, you might use a different API or a local database.
        FoodAnalysis(id: UUID(), foodName: foodName, calories: Int.random(in: 200...800), protein: Double.random(in: 10...40), carbs: Double.random(in: 20...80), fat: Double.random(in: 5...30), ingredients: ["Simulated Ingredient 1", "Simulated Ingredient 2"], timestamp: Date())
    }
    
    // MARK: - Core Data
    func createAndSaveFoodRecord(from analysis: FoodAnalysis) {
        let newRecord = FoodRecord(context: coreDataManager.viewContext)
        newRecord.id = analysis.id
        newRecord.foodName = analysis.foodName
        newRecord.calories = Int32(analysis.calories)
        newRecord.protein = analysis.protein
        newRecord.carbs = analysis.carbs
        newRecord.fat = analysis.fat
        // Assign the [String] array directly. Core Data with Transformable should handle the conversion.
        newRecord.ingredients = analysis.ingredients // Direct assignment
        newRecord.timestamp = analysis.timestamp
        
        if let image = capturedImage, let imageData = image.jpegData(compressionQuality: 0.8) { // Corrected syntax
            newRecord.imageData = imageData
        } else {
            newRecord.imageData = nil // Or a placeholder image data
        }
        
        coreDataManager.saveContext()
        foodAnalysisRecord = newRecord // Keep a reference if needed for passing to AnalysisView
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension AnalyzeFoodViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = error.localizedDescription
                self?.showingErrorAlert = true
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = uiImage
            Task { // Use Task for async analysis
                await self?.analyzeImage()
            }
        }
    }
}

// Assuming FoodAnalysis is a struct defined elsewhere
// struct FoodAnalysis: Codable, Identifiable { var id: UUID; var foodName: String; var calories: Int; var protein: Double; var carbs: Double; var fat: Double; var ingredients: [String]; var timestamp: Date }
// Assuming FoodRecord is a Core Data NSManagedObject with the correct attributes
// class FoodRecord: NSManagedObject { @NSManaged var id: UUID?; @NSManaged var foodName: String?; @NSManaged var calories: Int32; @NSManaged var protein: Double; @NSManaged var carbs: Double; @NSManaged var fat: Double; @NSManaged var ingredients: NSObject?; @NSManaged var timestamp: Date?; @NSManaged var imageData: Data? }
// Assuming OpenAIService has a public initializer
// Assuming ImageCompressor has a static func compressImage(_ image: UIImage) -> Data?
// Assuming CoreDataManager has a shared instance and a viewContext

// Dummy FoodAnalysis and FoodRecord definition for compilation if needed. Will be replaced by actual models.
// struct FoodAnalysis: Codable, Identifiable { var id: UUID; var foodName: String; var calories: Int; var protein: Double; var carbs: Double; var fat: Double; var ingredients: [String]; var timestamp: Date }
// class FoodRecord: NSManagedObject { @NSManaged var id: UUID?; @NSManaged var foodName: String?; @NSManaged var calories: Int32; @NSManaged var protein: Double; @NSManaged var carbs: Double; @NSManaged var fat: Double; @NSManaged var ingredients: NSObject?; @NSManaged var timestamp: Date?; @NSManaged var imageData: Data? } 