import Foundation
import Network // Import Network for NWPathMonitor

// Import the main module if Config and FoodAnalysis are defined there
// import FoodCalorieAnalyzer

class OpenAIService: NSObject { // Inherit from NSObject for URLSessionDelegate (if needed)
    
    // Use a shared singleton instance
    static let shared = OpenAIService()
    
    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession
    
    // Make the initializer public
    public override init() { // Use override init if subclassing NSObject
        // Reference Config using the module name if needed, e.g., FoodCalorieAnalyzer.Config
        guard let baseUrl = URL(string: Config.openAIBaseURL) else {
            fatalError("Invalid OpenAI Base URL in Config.swift")
        }
        self.baseURL = baseUrl
        self.apiKey = Config.openAIApiKey
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Config.timeoutInterval
        config.tlsMinimumSupportedProtocol = .tlsProtocol12 // Deprecated, but keeping for now
        config.tlsMaximumSupportedProtocol = .tlsProtocol13 // Deprecated, but keeping for now
        
        self.session = URLSession(configuration: config)
        
        super.init() // Call super.init()
    }
    
    // Helper function to wait for network connectivity
    private func waitForNetwork() async throws {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        return try await withCheckedThrowingContinuation { continuation in
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    monitor.cancel()
                    continuation.resume(with: .success(()))
                }
                // Add other path status handling if necessary
            }
            monitor.start(queue: queue)
        }
    }
    
    // Function to analyze food image using OpenAI Vision API
    func analyzeFoodImage(imageData: Data) async throws -> FoodAnalysis {
        try await waitForNetwork()
        
        guard let url = URL(string: baseURL.absoluteString + Config.visionEndpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let base64Image = imageData.base64EncodedString()
        
        let payload: [String: Any] = [
            "model": "gpt-4o", // Using gpt-4o as it is the latest and supports vision
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Analyze this food image and provide a structured JSON response with food name, calories, protein (g), carbs (g), fat (g), and a list of ingredients. If you cannot identify the food or its details, provide a default structure with null or zero values. Ensure the response is ONLY the JSON object."],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 500 // Increased tokens to ensure full JSON response
        ]
        
        let httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        request.httpBody = httpBody
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let responseBody = String(data: data, encoding: .utf8) ?? "N/A"
            throw NSError(domain: "OpenAIServiceError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed with status code \(statusCode). Response body: \(responseBody)"])
        }
        
        // Attempt to parse JSON response
        // The API response should now be ONLY the JSON object based on the prompt.
        let foodAnalysis = try JSONDecoder().decode(FoodAnalysis.self, from: data)
        
        return foodAnalysis
    }
}

// Assuming FoodAnalysis struct is defined elsewhere and is Decodable
// struct FoodAnalysis: Codable, Identifiable { var id: UUID; var foodName: String; var calories: Int; var protein: Double; carbs: Double; fat: Double; ingredients: [String]; timestamp: Date }
// Assuming Config is an enum or struct with static properties accessible here
// enum Config { static let openAIBaseURL: URL; static let openAIApiKey: String; static let visionEndpoint: String; static let timeoutInterval: TimeInterval } 