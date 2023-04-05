import Foundation

public struct PolyatomicResult<T: Codable & SchemaConvertible> {
    private var llm: LLM
    public var result: T
    
    public init(llm: LLM, result: T) {
        self.llm = llm
        self.result = result
    }
    
    public func then(_ prompt: String, with parameters: [String: Any]? = nil) async throws -> PolyatomicResult<String> {
        let stringRepresentation = try result.stringRepresentation()
        let prompt = "given this data: \"\(stringRepresentation)\"\nperform the following: \(prompt)"
        return try await llm.response(for: prompt, parameters: parameters)
    }
    
    public func then<M: Decodable & SchemaConvertible>(_ prompt: String,
                                                returningResultContaining type: M.Type,
                                                with parameters: [String: Any]? = nil
    ) async throws -> PolyatomicResult<M> {
        let stringRepresentation = try result.stringRepresentation()
        let prompt = "given this data: \"\(stringRepresentation)\"\nperform the following: \(prompt)"
        return try await llm.respond(withResultContaining: type, for: prompt, parameters: parameters)
    }
}
