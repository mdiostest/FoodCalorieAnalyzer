# Food Calorie Analyzer - Product Requirements Document

## Overview
Food Calorie Analyzer is an iOS application that uses AI to analyze food photos and provide nutritional information. The app leverages OpenAI's Vision API to identify food items and their nutritional content.

## Core Features

### 1. Camera & Photo Capture
- Camera interface with live preview
- Photo capture functionality
- Photo library access
- Image compression before API submission
- Support for both front and back cameras

### 2. Food Analysis
- OpenAI Vision API integration
- Structured JSON response parsing
- Nutritional information extraction:
  - Food name
  - Calories
  - Protein (g)
  - Carbs (g)
  - Fat (g)
  - Ingredients list

### 3. Data Management
- Core Data integration for local storage
- Food analysis history
- Calendar view of food records
- Editable analysis results
- Real-time calorie updates

### 4. User Interface
- Clean, intuitive design
- Camera view with capture controls
- Analysis results view
- Editable ingredient list
- History/calendar view
- Loading states and error handling

## Technical Specifications

### API Integration
```json
{
  "model": "gpt-4-vision-preview",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Analyze this food image..."
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,..."
          }
        }
      ]
    }
  ]
}
```

### Data Models
```swift
struct FoodAnalysis: Codable, Identifiable {
    let id: UUID
    let foodName: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let ingredients: [String]
    let timestamp: Date
}
```

### Core Data Schema
```swift
entity FoodRecord {
    attribute id: UUID
    attribute foodName: String
    attribute calories: Integer
    attribute protein: Double
    attribute carbs: Double
    attribute fat: Double
    attribute ingredients: Transformable
    attribute timestamp: Date
    attribute imageData: Binary
}
```

## Development Requirements

### Tools
- Cursor IDE
- SweetPad VS Code extension
- Xcode 14.0+
- Git for version control

### Dependencies
- SwiftUI
- Core Data
- AVFoundation
- OpenAI API

### Testing Requirements
- Camera functionality on simulator and device
- API integration testing
- Core Data persistence
- UI responsiveness
- Error handling

## Performance Requirements
- Image compression before API submission
- Responsive UI (< 100ms response time)
- Offline data persistence
- Efficient memory management

## Security Requirements
- Secure API key storage
- Local data encryption
- Privacy-focused image handling

## Future Enhancements
- User authentication
- Cloud sync
- Social sharing
- Meal planning
- Nutritional goals tracking 