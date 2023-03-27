import Foundation

public protocol LLM {
    func response(for prompt: String) async throws -> String
}
