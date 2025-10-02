import Foundation

public struct OpenAIMessage: Codable { public let role: String; public let content: String }
public struct OpenAIChatRequest: Codable {
  public let model: String
  public let messages: [OpenAIMessage]
}
public struct OpenAIChatResponse: Codable { public let id: String; public let choices: [Choice]
  public struct Choice: Codable { public let index: Int; public let message: OpenAIMessage }
}

public final class OpenAIService {
  private let apiKey: String
  private let session: URLSession

  public init(apiKey: String, session: URLSession = .shared) {
    self.apiKey = apiKey
    self.session = session
  }

  public func chat(model: String, messages: [OpenAIMessage]) async throws -> OpenAIChatResponse {
    guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { throw URLError(.badURL) }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    let body = OpenAIChatRequest(model: model, messages: messages)
    req.httpBody = try JSONEncoder().encode(body)
    let (data, resp) = try await session.data(for: req)
    guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
      let text = String(data: data, encoding: .utf8) ?? ""
      throw NSError(domain: "OpenAIService", code: (resp as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: text])
    }
    return try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
  }
}

