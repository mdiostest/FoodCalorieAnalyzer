# Food Calorie Analyzer iOS App

An iOS application that analyzes food calories and nutrients from photos using OpenAI's Vision API. Built with SwiftUI, Core Data, and modern iOS development tools.

## Features
- Food analysis using OpenAI Vision API
- Custom keyboard for food input (SweetPad integration)
- Real-time calorie and nutrient analysis
- Beautiful and intuitive UI
- History view with calendar integration
- Core Data persistence
- Image compression optimization

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
3. Obtain your OpenAI API key from [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys).
4. In the `FoodCalorieAnalyzer/Utils/Config.swift` file, replace `"YOUR_API_KEY_HERE"` with your actual API key.
    **Important:** Do not commit your actual API key to version control.
5. Build and run the project

## Development Setup
1. Install required tools:
   ```bash
   brew install xcode-build-server
   brew install xcbeautify
   brew install swiftformat
   ```

2. Configure SwiftFormat:
   - The project includes a `.swiftformat` configuration file
   - Run `swiftformat .` to format all Swift files

3. Set up SweetPad:
   - Install SweetPad VS Code extension
   - Configure simulator display settings

## Project Structure
- `Views/`: SwiftUI views
  - `SweetpadView.swift`: Main food analysis interface
  - `HistoryView.swift`: Food history and calendar view
  - `ContentView.swift`: Main tab navigation
- `ViewModels/`: MVVM view models
  - `HistoryViewModel.swift`: History management
- `Models/`: Data models
  - `FoodAnalysis.swift`: Food analysis data structure
  - `CoreData/`: Core Data models and persistence
- `Services/`: API and data services
  - `OpenAIService.swift`: OpenAI Vision API integration
  - `CoreDataManager.swift`: Core Data persistence
- `Utils/`: Helper functions
  - `ImageCompressor.swift`: Image optimization

## Development Workflow
1. Use Cursor IDE for development
2. Format code with SwiftFormat
3. Test on iOS simulator with SweetPad
4. Commit changes with meaningful messages

## Testing
- Food analysis works in simulator
- History view displays records correctly
- Core Data persistence verified
- UI responsiveness checked

## License
MIT License 