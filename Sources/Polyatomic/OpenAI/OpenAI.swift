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
        
        var endpoint = Endpoint(api, path, method: .post, timeout: 300, attachment: data)
        endpoint = endpoint.setting(contentType: .json)
        return endpoint
    }
    
    static func chat(api: API,
                     systemMessage: String? = nil,
                     userMessage: String,
                     maxTokens: Int,
                     temperature: Double,
                     topP: Double
    ) -> Endpoint {
        let path = "/v1/chat/completions?"
        
        let messages: [Message]
        
        if let systemMessage = systemMessage {
            messages = [
                .init(role: .user, content: systemMessage),
                .init(role: .user, content: userMessage)
            ]
        } else {
            messages = [.init(role: .user, content: userMessage)]
        }
        
        let attachment = OpenAIChatCompletionRequest(model: "gpt-3.5-turbo",
                                                     messages: messages,
                                                     max_tokens: maxTokens,
                                                     temperature: temperature,
                                                     top_p: topP)

        let data = try! JSONEncoder().encode(attachment)
        
        var endpoint = Endpoint(api, path, method: .post, timeout: 300, attachment: data)
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
        return try await response(for: prompt, constraints: "", maxTokens: 100, temperature: 0.5, topP: 1.0)
    }
    
    public func response<T: SchemaConvertible & Decodable>(for prompt: String) async throws -> T {
        let responseString = try await response(
            for: prompt,
            constraints: "You are an LLM that responds only with a JSON object that fits the following JSON Schema:\n\(T.schema())\nYou may not include any text besides what is contained within the opening and closing curly braces of the JSON response. You can not deviate from the schema's definition in any way otherwise the task you are given will fail. Do not include any other text outside of the schema's defintion.",
            maxTokens: 2000,
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
                                     userMessage: constraints + "\n" + userMessage,
                                     maxTokens: maxTokens,
                                     temperature: temperature,
                                     topP: topP)
        
        let response: ChatCompletionResponse = try await Networker.execute(endpoint)
        guard let text = response.choices.first?.message.content else { throw NetworkError.noDataOrBadResponse }
        return text
    }    
}
