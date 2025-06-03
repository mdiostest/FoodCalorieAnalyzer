import Foundation
import Network

// Temporary delegate class for initialization
private class TempURLSessionDelegate: NSObject, URLSessionDelegate {}

class OpenAIService: NSObject {
    static let shared = OpenAIService()
    private let baseURL = Config.openAIBaseURL
    private let apiKey = Config.openAIApiKey
    private let maxRetries = 3
    private let session: URLSession
    private let monitor = NWPathMonitor()
    private var isNetworkAvailable = false
    private let operationQueue = OperationQueue()
    private let networkQueue = DispatchQueue(label: "com.foodcalorieanalyzer.network", qos: .userInitiated)
    private var connectionPool: [URLSessionDataTask] = []
    private var currentTask: URLSessionDataTask?
    
    private override init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Config.timeoutInterval
        config.timeoutIntervalForResource = Config.timeoutInterval
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        
        // Add additional headers for better network handling
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "User-Agent": "FoodCalorieAnalyzer/1.0",
            "Connection": "keep-alive",
            "Keep-Alive": "timeout=60, max=1000"
        ]
        
        // Configure TLS settings
        config.tlsMinimumSupportedProtocol = .tlsProtocol12
        config.tlsMaximumSupportedProtocol = .tlsProtocol13
        
        // Configure connection pooling
        config.httpMaximumConnectionsPerHost = 1
        config.shouldUseExtendedBackgroundIdleMode = true
        
        // Disable QUIC to use basic HTTP/1.1
        config.httpShouldUsePipelining = false
        config.httpShouldSetCookies = false
        
        // Configure operation queue
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
        
        // Create a temporary delegate
        let delegate = TempURLSessionDelegate()
        
        // Initialize session with delegate before super.init()
        self.session = URLSession(configuration: config, delegate: delegate, delegateQueue: operationQueue)
        
        super.init()
        
        // Start network monitoring
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isNetworkAvailable = path.status == .satisfied
            print("DEBUG: Network status changed - Available: \(self?.isNetworkAvailable ?? false)")
            
            // Log network type
            if path.usesInterfaceType(.wifi) {
                print("DEBUG: Using WiFi connection")
            } else if path.usesInterfaceType(.cellular) {
                print("DEBUG: Using cellular connection")
            }
            
            // Log connection quality
            if path.isExpensive {
                print("DEBUG: Connection is expensive (e.g., cellular data)")
            }
            if path.isConstrained {
                print("DEBUG: Connection is constrained (e.g., low data mode)")
            }
            
            // If network becomes available, retry any failed request
            if path.status == .satisfied {
                print("DEBUG: Network became available, ready for requests")
            }
        }
        monitor.start(queue: networkQueue)
    }
    
    deinit {
        monitor.cancel()
        session.invalidateAndCancel()
        connectionPool.forEach { $0.cancel() }
        currentTask?.cancel()
    }
    
    private func waitForNetwork() async throws {
        if isNetworkAvailable {
            return
        }
        
        print("DEBUG: Waiting for network connection...")
        for attempt in 0..<10 { // Wait up to 10 seconds
            if isNetworkAvailable {
                print("DEBUG: Network connection established")
                return
            }
            print("DEBUG: Network wait attempt \(attempt + 1)/10")
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No network connection available. Please check your internet connection and try again."])
    }
    
    private func createRequest(with imageData: Data) throws -> URLRequest {
        let base64Image = imageData.base64EncodedString()
        
        let prompt = """
        Analyze this food image and provide the following information in JSON format:
        {
            "foodName": "name of the food",
            "calories": number,
            "protein": number in grams,
            "carbs": number in grams,
            "fat": number in grams,
            "ingredients": ["list", "of", "ingredients"]
        }
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500
        ]
        
        guard let url = URL(string: baseURL + Config.visionEndpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Force HTTP/1.1
        request.setValue("HTTP/1.1", forHTTPHeaderField: "Connection")
        
        return request
    }
    
    func analyzeFoodImage(_ imageData: Data) async throws -> FoodAnalysis {
        try await waitForNetwork()
        
        let request = try createRequest(with: imageData)
        print("DEBUG: Making API request to: \(request.url?.absoluteString ?? "")")
        print("DEBUG: Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        var retryCount = 0
        var lastError: Error?
        
        while retryCount < maxRetries {
            do {
                // Cancel any existing task
                currentTask?.cancel()
                
                let (data, response) = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
                    let task = session.dataTask(with: request) { [weak self] data, response, error in
                        if let error = error {
                            print("DEBUG: Network error: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                            return
                        }
                        guard let data = data, let response = response else {
                            print("DEBUG: No data or response received")
                            continuation.resume(throwing: URLError(.badServerResponse))
                            return
                        }
                        continuation.resume(returning: (data, response))
                    }
                    
                    // Store current task
                    self.currentTask = task
                    
                    // Add task to connection pool
                    connectionPool.append(task)
                    task.resume()
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("DEBUG: Invalid response type")
                    throw URLError(.badServerResponse)
                }
                
                print("DEBUG: Response status code: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("DEBUG: Response body: \(responseString)")
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    // Success case
                    let decoder = JSONDecoder()
                    let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
                    
                    guard let content = openAIResponse.choices.first?.message.content,
                          let jsonData = content.data(using: String.Encoding.utf8) else {
                        print("DEBUG: Failed to extract content from response")
                        throw URLError(.cannotParseResponse)
                    }
                    
                    print("DEBUG: Extracted content: \(content)")
                    
                    let foodAnalysis = try decoder.decode(FoodAnalysis.self, from: jsonData)
                    return foodAnalysis
                    
                case 401:
                    throw NSError(domain: "OpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication failed. Please check your API key."])
                    
                case 404:
                    if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorJson["error"] as? [String: Any],
                       let message = errorMessage["message"] as? String {
                        throw NSError(domain: "OpenAI", code: 404, userInfo: [NSLocalizedDescriptionKey: message])
                    }
                    throw URLError(.badServerResponse)
                    
                default:
                    if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorJson["error"] as? [String: Any],
                       let message = errorMessage["message"] as? String {
                        throw NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                    }
                    throw URLError(.badServerResponse)
                }
                
            } catch {
                lastError = error
                print("DEBUG: Attempt \(retryCount + 1) failed with error: \(error)")
                
                // Don't retry on authentication errors
                if let nsError = error as NSError?,
                   nsError.domain == "OpenAI" && nsError.code == 401 {
                    throw error
                }
                
                if retryCount < maxRetries - 1 {
                    retryCount += 1
                    let delay = pow(2.0, Double(retryCount)) // Exponential backoff
                    print("DEBUG: Retrying in \(delay) seconds...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                break
            }
        }
        
        print("DEBUG: All retry attempts failed")
        throw lastError ?? URLError(.unknown)
    }
}

// MARK: - URLSessionDelegate
extension OpenAIService: URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("DEBUG: URLSession became invalid with error: \(error?.localizedDescription ?? "none")")
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("DEBUG: Received authentication challenge")
        completionHandler(.performDefaultHandling, nil)
    }
}

// OpenAI API response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
} 