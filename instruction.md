# Food Calorie Analyzer - Product Requirements Document (PRD)

## Overview
The Food Calorie Analyzer is an iOS app that allows users to take a photo of food, analyze its ingredients and calorie information using the OpenAI Vision API, edit the analyzed data, and save logs to a calendar history.

## Features
1. **Camera Capture:**
   - Users can take a photo of food using the device camera or simulator.
   - Support for both real device and simulator environments.

2. **Food Analysis:**
   - Integration with OpenAI Vision API to analyze food images.
   - Structured JSON response for ingredient and calorie details.

3. **Editable Analysis:**
   - Users can edit the analyzed data, including ingredients and calorie information.
   - Real-time updates to calorie calculations.

4. **History/Calendar Log:**
   - Save analyzed food records to a calendar history.
   - View past food logs with details.

## API Integration
- **OpenAI Vision API:**
  - Endpoint: `https://api.openai.com/v1/chat/completions`
  - API Key: Use a test key for development.
  - Structured JSON response for food analysis.

## Data Models
- **FoodAnalysis:**
  - Properties: `foodName`, `calories`, `protein`, `carbs`, `fat`, `ingredients`.
  - Used to store and display analyzed food details.

- **FoodRecord:**
  - Core Data entity for persisting food analysis records.
  - Properties: `foodName`, `calories`, `protein`, `carbs`, `fat`, `ingredients`, `timestamp`.

## Development Tools
- **Cline (VS Code AI extension):** For AI agent-based development.
- **SweetPad (VS Code iOS extension):** For simulator testing.
- **Xcode:** For project base and iOS development.
- **GitHub:** For version control and commit history.

## Deliverables
- Fully functional iOS app with all features implemented.
- Development assets: `instruction.md`, `.cursor-rules`, `README.md`.
- GitHub repo with commit history.

## Evaluation Criteria
- Use of AI tools (Cursor, SweetPad, LLM prompting).
- Working feature set.
- Debugging via Cursor AI logs.
- Code structure: MVVM preferred.
- UI: Basic, but functional.
- Clarity in instruction.md and .cursor-rules.

## Bonus (Optional)
- Image compression optimization before sending to OpenAI.
- UI improvement (better camera/edit screens).
- Deployment on TestFlight.

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