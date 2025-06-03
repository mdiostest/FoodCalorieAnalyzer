import Foundation

enum Config {
    // OpenAI Configuration
    static let openAIBaseURL = "https://api.openai.com/v1"
    static let openAIApiKey = "YOUR_API_KEY_HERE" // Replace with your actual API key
    static let visionEndpoint = "/chat/completions"
    
    // Image Configuration
    static let maxImageSize: CGFloat = 1024
    static let imageCompressionQuality: CGFloat = 0.7
    
    // API Configuration
    static let timeoutInterval: TimeInterval = 30
    static let maxRetries = 3
} 