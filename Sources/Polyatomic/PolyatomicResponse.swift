import Foundation

public struct PolyatomicResult<T> {
    private var llm: LLM
    var result: T
    
    public init(llm: LLM, result: T) {
        self.llm = llm
        self.result = result
    }
    
    public func then(_ prompt: String, with parameters: [String: Any]? = nil) async throws -> PolyatomicResult<String> {
        try await llm.response(for: prompt, parameters: parameters)
    }
    
    public func then<M: Decodable & SchemaConvertible>(_ prompt: String,
                                                returningResultContaining type: M.Type,
                                                with parameters: [String: Any]? = nil
    ) async throws -> PolyatomicResult<M> {
        try await llm.respond(withResultContaining: type, for: prompt, parameters: parameters)
    }
}
