import Foundation
import CoreLocation

public struct ProviderRestaurantDTO: Sendable {
  public let externalId: String
  public let name: String
  public let latitude: Double
  public let longitude: Double
  public let rating: Double?
  public let priceLevel: Int?
  public let categories: [String]?
  public let isOpen: Bool?
  public let photoURL: String?
  public let websiteURL: String?
}

public struct ProviderMenuItemDTO: Sendable {
  public let externalId: String
  public let name: String
  public let priceCents: Int
  public let category: String
  public let description: String?
  public let tags: [String]?
}

public protocol RestaurantProviderAPI {
  func searchNearby(center: CLLocationCoordinate2D, radiusMeters: Double, limit: Int) async throws -> [ProviderRestaurantDTO]
  func fetchMenu(for externalRestaurantId: String) async throws -> [ProviderMenuItemDTO]
}

