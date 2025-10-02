import XCTest
import CoreData
@testable import RestaurantAIKit

final class RecommendationServiceTests: XCTestCase {
  func testRecommendSimple() throws {
    let container = PersistentContainer.shared
    let ctx = container.viewContext

    let user = User(context: ctx)
    user.id = UUID()
    user.email = "test@example.com"
    user.createdAt = Date()

    let prefs = UserPreferences(context: ctx)
    prefs.user = user
    prefs.prefersCheaper = true
    prefs.prefersFaster = false
    prefs.lovesSweets = true
    prefs.dislikesSpicy = false
    user.preferences = prefs

    let weights = UserWeights(context: ctx)
    weights.user = user
    weights.flavorWeight = 0.4
    weights.priceWeight = 0.25
    weights.ratingWeight = 0.2
    weights.distanceWeight = 0.15
    user.weights = weights

    let r = Restaurant(context: ctx)
    r.id = UUID()
    r.name = "Cafe Dessert"
    r.latitude = 41.0
    r.longitude = 29.0
    r.rating = 4.5
    r.deliveryAvailable = true
    r.createdAt = Date()

    let m = MenuItem(context: ctx)
    m.id = UUID()
    m.restaurant = r
    m.name = "Tiramisu"
    m.priceCents = 5000
    m.category = "dessert"
    m.tags = ["light","low_sugar"]

    try ctx.save()

    let service = RecommendationService(context: ctx)
    let center = CLLocationCoordinate2D(latitude: 41.0, longitude: 29.0)
    let results = try service.recommend(for: user, center: center, radiusMeters: 2000, userMessage: "hafif tatlı az şekerli")
    XCTAssertFalse(results.isEmpty)
    XCTAssertEqual(results.first?.menuItem.name, "Tiramisu")
  }
}

