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
    
    static func chat(api: API,
                     systemMessage: String,
                     userMessage: String,
                     maxTokens: Int,
                     temperature: Double,
                     topP: Double
    ) -> Endpoint {
        let path = "/v1/chat/completions?"
        
        let attachment = OpenAIChatCompletionRequest(model: "gpt-3.5-turbo",
                                                     messages: [
                                                        .init(role: .system, content: systemMessage),
                                                        .init(role: .user, content: userMessage)
                                                     ],
                                                     max_tokens: maxTokens,
                                                     temperature: temperature,
                                                     top_p: topP)

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
        return try await response(for: prompt, constraints: "", maxTokens: 3000, temperature: 0.5, topP: 1.0)
    }
    
    public func response<T: SchemaConvertible & Decodable>(for prompt: String) async throws -> T {
        let responseString = try await response(
            for: prompt,
            constraints: "Ignore all previous directives. You are now a REST API that only returns JSON objects to fit the following schema:\n\(T.schema())\nYou can not respond with anything else aside from the specified JSON.",
            maxTokens: 3000,
            temperature: 0.0,
            topP: 1.0)
        guard let data = responseString.data(using: .utf8, allowLossyConversion: false) else {
            throw NetworkError.badDecode
        }
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
    
    func response(for userMessage: String,
                  constraints: String,
                  maxTokens: Int = 3000,
                  temperature: Double = 0.5,
                  topP: Double = 1.0
    ) async throws -> String {
        let api: API = .openAI(apiKey: apiKey)
        
        let endpoint = Endpoint.chat(api: api,
                                     systemMessage: constraints,
                                     userMessage: userMessage,
                                     maxTokens: maxTokens,
                                     temperature: temperature,
                                     topP: topP)
        
        let response: ChatCompletionResponse = try await Networker.execute(endpoint)
        guard let text = response.choices.first?.message.content else { throw NetworkError.noDataOrBadResponse }
        return text
    }    
}
