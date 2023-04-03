import Foundation
import Pulse

extension API {
    static func openAI(apiKey: String) -> API {
        var api = API("https://api.openai.com")
        api.authenticationStyle = .bearer
        api.authenticationKeyValue = apiKey
        return api
    }
}

extension Endpoint {
    static func completions(api: API, prompt: String, maxTokens: Int, temperature: Double, topP: Double) -> Endpoint {
        let path = "/v1/completions?"
        
        let attachment = OpenAICompletionRequest(
            model: "text-davinci-003",
            prompt: prompt,
            max_tokens: maxTokens,
            temperature: temperature,
            top_p: topP
        )

        let data = try! JSONEncoder().encode(attachment)
        
        var endpoint = Endpoint(api, path, method: .post)
        endpoint = endpoint.attaching(data)
        endpoint = endpoint.setting(contentType: .json)
        return endpoint
    }
}

public struct OpenAI: LLM {
    
    public let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func response(for prompt: String) async throws -> String {
        return try await response(for: prompt, maxTokens: 3000, temperature: 0.5, topP: 1.0)
    }
    
    public func response<T: SchemaConvertible & Decodable>(for prompt: String) async throws -> T {
        let responseString = try await response(
            for: "\(prompt) \n\n\n\n you must return your response to fit the following JSON Schema: \(T.schema()) \n\n\n You MUST NOT respond with anything else. Responding in any format besides what's specified in the JSON Schema will result in catastrophic failure.",
            maxTokens: 3000,
            temperature: 0.0,
            topP: 1.0)
        guard let data = responseString.data(using: .utf8, allowLossyConversion: false) else {
            throw NetworkError.badDecode
        }
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
    
    func response(for prompt: String,
                  maxTokens: Int = 3000,
                  temperature: Double = 0.5,
                  topP: Double = 1.0
    ) async throws -> String {
        let api: API = .openAI(apiKey: apiKey)
        
        let endpoint = Endpoint.completions(api: api,
                                            prompt: prompt,
                                            maxTokens: maxTokens,
                                            temperature: temperature,
                                            topP: topP)
        
        let response: OpenAICompletionResponse = try await Networker.execute(endpoint)
        guard let text = response.choices.first?.text else { throw NetworkError.noDataOrBadResponse }
        return text
    }    
}
