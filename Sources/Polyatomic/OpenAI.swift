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
    static func completions(api: API, prompt: String, maxTokens: Int, temperature: Float, topP: Float) -> Endpoint {
        let path = "/v1/engines/davinci-codex/completions?"
        let queryItems = [
            URLQueryItem(name: "prompt", value: prompt),
            URLQueryItem(name: "max_tokens", value: "\(maxTokens)"),
            URLQueryItem(name: "temperature", value: "\(temperature)"),
            URLQueryItem(name: "top_p", value: "\(topP)")
        ]
        var endpoint = Endpoint(api, path, method: .post)
        return endpoint.addingQueryItems(queryItems)
    }
}

public struct OpenAI: LLM {
    let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func response(for prompt: String) async throws -> String {
        return try await response(for: prompt, maxTokens: 3000, temperature: 0.0, topP: 1.0)
    }
    
    func response(for prompt: String,
                  maxTokens: Int = 3000,
                  temperature: Float = 0.5,
                  topP: Float = 1.0
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
