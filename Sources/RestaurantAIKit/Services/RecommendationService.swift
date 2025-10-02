import Foundation
import CoreData
import CoreLocation

public struct RecommendationCandidate {
  public let restaurant: Restaurant
  public let menuItem: MenuItem
  public let reason: String
  public let score: Double
}

public final class RecommendationService {
  private let context: NSManagedObjectContext

  public init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
    self.context = context
  }

  public func recommend(
    for user: User,
    center: CLLocationCoordinate2D,
    radiusMeters: Double,
    userMessage: String,
    limit: Int = 10
  ) throws -> [RecommendationCandidate] {
    // Very simplified heuristics for demo
    let restStore = RestaurantStore(context: context)
    let menuStore = MenuStore(context: context)
    let restaurants = try restStore.fetchNearby(center: center, radiusMeters: radiusMeters, limit: 100)

    let intention = inferIntent(from: userMessage)
    var candidates: [RecommendationCandidate] = []

    for r in restaurants {
      let menus = try menuStore.fetchByRestaurant(r)
      for m in menus where matches(intent: intention, item: m) {
        let (flavor, price, rating, distance) = scoreComponents(user: user, restaurant: r, item: m, center: center)
        let weights = weights(for: user)
        let total = flavor * weights.flavor + price * weights.price + rating * weights.rating + distance * weights.distance
        let reason = "\(intention.primary ?? "öneri"): tat uyumu=\(flavor.rounded(to: 2)), fiyat=\(price.rounded(to: 2)), puan=\(rating.rounded(to: 2)), mesafe=\(distance.rounded(to: 2))"
        candidates.append(.init(restaurant: r, menuItem: m, reason: reason, score: total))
      }
    }

    return candidates.sorted { $0.score > $1.score }.prefix(limit).map { $0 }
  }

  private func matches(intent: Intention, item: MenuItem) -> Bool {
    let category = item.category.lowercased()
    let tags = item.tags?.map { $0.lowercased() } ?? []

    // Primary category/topic match
    if let primary = intent.primary?.lowercased() {
      var primaryOk = false
      if category.contains(primary) || tags.contains(primary) {
        primaryOk = true
      }
      if primary == "dessert" {
        let dessertHints = ["dessert","tatlı","sweet","cake","brownie","tiramisu","cheesecake","sufle","mozaik","pasta"]
        if dessertHints.contains(where: { category.contains($0) || tags.contains($0) }) {
          primaryOk = true
        }
      }
      if !primaryOk { return false }
    }

    // Trait match (if traits specified, require at least one)
    if intent.traits.isEmpty { return true }
    return intent.traits.contains(where: { t in tags.contains(t) })
  }

  private func weights(for user: User) -> (flavor: Double, price: Double, rating: Double, distance: Double) {
    let w = user.weights
    return (
      flavor: w?.flavorWeight ?? 0.4,
      price: w?.priceWeight ?? 0.25,
      rating: w?.ratingWeight ?? 0.2,
      distance: w?.distanceWeight ?? 0.15
    )
  }

  private func scoreComponents(user: User, restaurant: Restaurant, item: MenuItem, center: CLLocationCoordinate2D) -> (Double, Double, Double, Double) {
    // flavor
    let intent = inferIntent(from: nil)
    let flavor = flavorScore(for: item, intention: intent)
    // price (lower is better)
    let price = priceScore(for: item, user: user)
    // rating (normalize 0..1)
    let rating = max(0.0, min(1.0, restaurant.rating / 5.0))
    // distance (closer is better)
    let distanceMeters = center.distance(to: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude))
    let distance = distanceScore(distanceMeters)
    return (flavor, price, rating, distance)
  }

  private func priceScore(for item: MenuItem, user: User) -> Double {
    let price = Double(item.priceCents)
    let minB = Double(user.preferences?.minBudgetCents ?? 0)
    let maxB = Double(user.preferences?.maxBudgetCents ?? 0)
    if maxB > 0 {
      if price <= minB { return 1.0 }
      if price >= maxB { return 0.0 }
      return 1.0 - (price - minB) / max(1.0, (maxB - minB))
    }
    // fallback: inverse-log curve
    return 1.0 / log2(max(2.0, price / 100.0))
  }

  private func distanceScore(_ meters: Double) -> Double {
    // 0m -> 1.0, 2km -> ~0.3, 5km -> ~0.15
    let km = meters / 1000.0
    let score = 1.0 / (1.0 + km)
    return max(0.0, min(1.0, score))
  }

  private func flavorScore(for item: MenuItem, intention: Intention) -> Double {
    guard let tags = item.tags?.map({ $0.lowercased() }) else { return 0.5 }
    var s = 0.5
    if let primary = intention.primary, tags.contains(primary) { s += 0.3 }
    for t in intention.traits { if tags.contains(t) { s += 0.1 } }
    return max(0.0, min(1.0, s))
  }

  private struct Intention { let primary: String?; let traits: [String] }

  private func inferIntent(from message: String?) -> Intention {
    guard let text = message?.lowercased() else { return .init(primary: nil, traits: []) }
    let dessertKeywords = ["tatlı","dessert","çikolata","sufle","cheesecake","brownie","tiramisu"]
    let lightKeywords = ["hafif","light","az şeker","low sugar","az şekerli"]
    var primary: String? = nil
    if dessertKeywords.contains(where: { text.contains($0) }) { primary = "dessert" }
    var traits: [String] = []
    if lightKeywords.contains(where: { text.contains($0) }) { traits.append("light") }
    if text.contains("çikolata") { traits.append("chocolate") }
    if text.contains("az şeker") || text.contains("az şekerli") { traits.append("low_sugar") }
    return .init(primary: primary, traits: traits)
  }
}

private extension CLLocationCoordinate2D {
  func distance(to other: CLLocationCoordinate2D) -> Double {
    let loc1 = CLLocation(latitude: latitude, longitude: longitude)
    let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
    return loc1.distance(from: loc2)
  }
}

private extension Double {
  func rounded(to places: Int) -> Double {
    let p = pow(10.0, Double(places))
    return (self * p).rounded() / p
  }
}

