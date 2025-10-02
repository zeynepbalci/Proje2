import Foundation

enum WebMenuParserError: Error { case invalidURL, network, decode }

struct JSONLD: Decodable { let context: String?; let type: String?; let graph: [Node]?; let itemListElement: [Node]?; let hasMenuSection: [Node]?; let name: String?; let description: String?; let offers: NodeOrArray?; let url: String?; let menuAddOn: NodeOrArray?; let menuItems: [Node]?; let menuItem: NodeOrArray?; let price: String?; let priceCurrency: String?; let category: String?; let image: String?; let servesCuisine: String?; let acceptsReservations: NodeOrArray?; let hasMenu: NodeOrArray?; let mainEntity: Node?; let potentialAction: NodeOrArray?; let about: NodeOrArray?; let publisher: Node?; let author: Node?; let headline: String?; let articleBody: String?; let item: Node?; let itemOffered: Node?; let additionalType: NodeOrArray?; let sameAs: NodeOrArray?
  enum CodingKeys: String, CodingKey { case context = "@context", type = "@type", graph = "@graph", itemListElement, hasMenuSection, name, description, offers, url, menuAddOn, menuItems, menuItem, price, priceCurrency, category, image, servesCuisine, acceptsReservations, hasMenu, mainEntity, potentialAction, about, publisher, author, headline, articleBody, item, itemOffered, additionalType, sameAs }
}

struct Node: Decodable { let type: String?; let name: String?; let description: String?; let offers: NodeOrArray?; let itemOffered: Node?; let url: String?; let price: String?; let priceCurrency: String?; let category: String?; let hasMenuSection: [Node]?; let menuItems: [Node]?; let menuItem: NodeOrArray?; let image: String?
  enum CodingKeys: String, CodingKey { case type = "@type", name, description, offers, itemOffered, url, price, priceCurrency, category, hasMenuSection, menuItems, menuItem, image }
}

enum NodeOrArray: Decodable { case node(Node), array([Node])
  init(from decoder: Decoder) throws {
    let c = try decoder.singleValueContainer()
    if let node = try? c.decode(Node.self) { self = .node(node); return }
    if let arr = try? c.decode([Node].self) { self = .array(arr); return }
    self = .array([])
  }
  var nodes: [Node] { switch self { case .node(let n): return [n]; case .array(let a): return a } }
}

public enum WebMenuParser {
  public static func fetchAndParseMenu(from websiteURL: String, session: URLSession = .shared) async throws -> [ProviderMenuItemDTO] {
    guard let url = URL(string: websiteURL) else { throw WebMenuParserError.invalidURL }
    var req = URLRequest(url: url)
    req.setValue("text/html,application/xhtml+xml,application/json", forHTTPHeaderField: "Accept")
    let (data, _) = try await session.data(for: req)
    guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
      throw WebMenuParserError.decode
    }
    return try parseJSONLD(fromHTML: html, baseURL: url)
  }

  static func parseJSONLD(fromHTML html: String, baseURL: URL?) throws -> [ProviderMenuItemDTO] {
    let scriptPattern = #"<script[^>]*type=\"application/ld\+json\"[^>]*>([\s\S]*?)</script>"#
    let regex = try NSRegularExpression(pattern: scriptPattern, options: [.caseInsensitive])
    let range = NSRange(location: 0, length: html.utf16.count)
    let matches = regex.matches(in: html, options: [], range: range)
    var items: [ProviderMenuItemDTO] = []
    let decoder = JSONDecoder()
    for m in matches {
      guard m.numberOfRanges > 1, let r = Range(m.range(at: 1), in: html) else { continue }
      let jsonText = String(html[r])
      // Some sites put multiple JSON objects; try to decode array first
      if let data = jsonText.data(using: .utf8) {
        if let arr = try? decoder.decode([JSONLD].self, from: data) {
          for obj in arr { items.append(contentsOf: extractMenuItems(from: obj)) }
          continue
        }
        if let obj = try? decoder.decode(JSONLD.self, from: data) {
          items.append(contentsOf: extractMenuItems(from: obj))
          continue
        }
      }
    }
    return normalize(items)
  }

  private static func extractMenuItems(from root: JSONLD) -> [ProviderMenuItemDTO] {
    var results: [ProviderMenuItemDTO] = []
    func handleNode(_ n: Node) {
      // MenuItem may appear as itemOffered or direct node
      if let t = n.type?.lowercased(), t.contains("menuitem") || t.contains("offer") {
        let name = n.name ?? n.itemOffered?.name ?? "Menu Item"
        let priceStr = n.price ?? n.offers?.nodes.first?.price
        let priceCents = (Double(priceStr ?? "") ?? 0.0) * 100.0
        let desc = n.description ?? n.itemOffered?.description
        let category = n.category ?? "menu"
        let tags: [String] = []
        results.append(.init(externalId: UUID().uuidString, name: name, priceCents: Int(priceCents), category: category, description: desc, tags: tags))
      }
      if let offers = n.offers?.nodes { for o in offers { handleNode(o) } }
      if let items = n.menuItems { for child in items { handleNode(child) } }
      if let child = n.menuItem { for c in child.nodes { handleNode(c) } }
      if let sections = n.hasMenuSection { for s in sections { handleNode(s) } }
    }

    if let graph = root.graph { for n in graph { handleNode(n) } }
    if let items = root.itemListElement { for n in items { handleNode(n) } }
    if let sections = root.hasMenuSection { for n in sections { handleNode(n) } }
    if let main = root.mainEntity { handleNode(main) }

    return results
  }

  private static func normalize(_ items: [ProviderMenuItemDTO]) -> [ProviderMenuItemDTO] {
    var seen = Set<String>()
    var out: [ProviderMenuItemDTO] = []
    for i in items {
      let key = "\(i.name.lowercased())-\(i.category.lowercased())-\(i.priceCents)"
      if !seen.contains(key) { seen.insert(key); out.append(i) }
    }
    return out
  }
}

