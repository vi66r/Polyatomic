import Foundation

enum OpenAIModel: String {
    // GPT-4 Models
    case gpt4 = "gpt-4"
    case gpt4_0314 = "gpt-4-0314"
    case gpt4_32k = "gpt-4-32k"
    case gpt4_32k_0314 = "gpt-4-32k-0314"

    // GPT-3.5 Models
    case gpt3_5Turbo = "gpt-3.5-turbo"
    case gpt3_5Turbo_0301 = "gpt-3.5-turbo-0301"
    case textDavinci003 = "text-davinci-003"
    case textDavinci002 = "text-davinci-002"
    case codeDavinci002 = "code-davinci-002"
}

