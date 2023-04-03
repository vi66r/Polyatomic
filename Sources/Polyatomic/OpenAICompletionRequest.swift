import Foundation

struct OpenAICompletionRequest: Codable {
    
    let model: String
    let prompt: String
    let max_tokens: Int
    let temperature: Double
    let top_p: Double
    
//    "model" : "gpt-3.5-turbo",
//    "prompt" : prompt,
//    "max_tokens" : maxTokens,
//    "temperature" : temperature,
//    "top_p:" : topP
    
    
}
