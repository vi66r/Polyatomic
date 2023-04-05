import Foundation

public struct PolyatomicResult<T: Codable & SchemaConvertible> {
    private var llm: LLM
    public var result: T
    
    public init(llm: LLM, result: T) {
        self.llm = llm
        self.result = result
    }
    
    public func then(_ prompt: String, using model: LLM? = nil, with parameters: [String: Any]? = nil) async throws -> PolyatomicResult<String> {
        let stringRepresentation = try result.stringRepresentation()
        let prompt = "given this data: \"\(stringRepresentation)\"\nperform the following: \"\(prompt)\"\nThere is no need to mention the data used. Respond in a friendly and charming manner" // mood/response type could be a variable or "parameter"
        return try await (model ?? llm).response(for: prompt, parameters: parameters)
    }
    
    public func then<M: Decodable & SchemaConvertible>(_ prompt: String,
                                                       using model: LLM? = nil,
                                                returningResultContaining type: M.Type,
                                                with parameters: [String: Any]? = nil
    ) async throws -> PolyatomicResult<M> {
        let stringRepresentation = try result.stringRepresentation()
        let prompt = "given this data: \"\(stringRepresentation)\"\nperform the following: \(prompt)"
        return try await (model ?? llm).respond(withResultContaining: type, for: prompt, parameters: parameters)
    }
}
