import Foundation

public protocol LLM {
    func response(for prompt: String, parameters: [String: Any]?) async throws -> PolyatomicResult<String>
    
    // different LLMs will have different possible parameter implementations, so we use a less structured form of data
    func respond<T: SchemaConvertible & Decodable>(
        withResultContaining type: T.Type,
        for prompt: String,
        parameters: [String: Any]?
    ) async throws -> PolyatomicResult<T>
    
    func tokenSummarize(input: String) async throws -> String
}
