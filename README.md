# Food Calorie Analyzer iOS App

An iOS application that analyzes food calories and nutrients from photos using OpenAI's Vision API.

## Features
- Camera capture for food photos
- OpenAI Vision API integration for food analysis
- Editable ingredient view with real-time calorie updates
- History/calendar log view for food records
- MVVM architecture
- Core Data integration for local storage

## Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- OpenAI API Key
- Cursor IDE
- SweetPad VS Code extension

## Installation
1. Clone the repository
2. Open `FoodCalorieAnalyzer.xcodeproj` in Xcode
3. Add your OpenAI API key in `Config.swift`
4. Build and run the project

## Project Structure
- `Views/`: SwiftUI views
  - `CameraView.swift`: Camera interface and photo capture
  - `ImagePicker.swift`: Photo library picker
  - `AnalysisView.swift`: Food analysis results and editing
  - `HistoryView.swift`: Food history and calendar view
- `ViewModels/`: MVVM view models
  - `CameraViewModel.swift`: Camera and analysis logic
  - `HistoryViewModel.swift`: History management
- `Models/`: Data models
  - `FoodAnalysis.swift`: Food analysis data structure
  - `CoreData/`: Core Data models and persistence
- `Services/`: API and camera services
  - `OpenAIService.swift`: OpenAI Vision API integration
- `Utils/`: Helper functions and extensions
  - `Config.swift`: Configuration settings
  - `ImageCompressor.swift`: Image optimization

## Development Setup
1. Install Cursor IDE
2. Install SweetPad VS Code extension
3. Configure OpenAI API key
4. Build and run on iOS simulator or device

## Build Steps
1. Open project in Xcode
2. Select target device/simulator
3. Build and run (⌘R)

## Testing
- Camera functionality works on both simulator and device
- OpenAI API integration tested with sample images
- Core Data persistence verified
- UI responsiveness checked on different device sizes

## License
MIT License 