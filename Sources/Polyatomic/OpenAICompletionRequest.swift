import Foundation

struct OpenAICompletionRequest: Codable {
    let model: String
    let prompt: String
    let max_tokens: Int
    let temperature: Double
    let top_p: Double
}
