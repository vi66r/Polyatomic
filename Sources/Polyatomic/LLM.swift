import Foundation

public protocol LLM {
    func response(for prompt: String) async throws -> String
    func response<T: SchemaConvertible & Decodable>(for prompt: String) async throws -> T
}
