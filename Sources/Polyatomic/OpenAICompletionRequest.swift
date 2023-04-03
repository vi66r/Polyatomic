import Foundation

struct OpenAICompletionRequest: Codable {
    var model: String
    var prompt: String
    var max_tokens: Int
    var temperature: Double
    var top_p: Double
}

public struct Message: Equatable, Codable, Hashable {
    public enum Role: String, Equatable, Codable, Hashable {
        case system
        case user
        case assistant
    }

    public var role: Role
    public var content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

struct OpenAIChatCompletionRequest: Codable {
    var model: String
    var messages: [Message]
    var max_tokens: Int
    var temperature: Double
    var top_p: Double
}
