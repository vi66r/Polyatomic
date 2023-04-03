import Foundation

public struct OpenAICompletionResponse: Codable {
    let id: String?
    let object: String
    let created: Int
    let model: String
    let usage: Usage
    let choices: [Choice]
}

public struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

public struct Choice: Codable {
    let text: String
    let index: Int
    let logprobs: Logprobs?
    let finish_reason: String
}

public struct Logprobs: Codable {
    let tokens: [String]
    let token_logprobs: [Double]
    let top_logprobs: [[String: Double]]
    let text_offset: [Int]
}

