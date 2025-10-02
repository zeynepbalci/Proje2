import Foundation
import Combine
import CoreLocation
import RestaurantAIKit

@MainActor
public final class HomeViewModel: ObservableObject {
  @Published public private(set) var restaurants: [Restaurant] = []
  @Published public var center: CLLocationCoordinate2D? = nil
  @Published public var radius: Double = 2000

  private let restaurantStore: RestaurantStore

  public init(restaurantStore: RestaurantStore = RestaurantStore()) {
    self.restaurantStore = restaurantStore
  }

  public func loadNearby() {
    guard let center else { return }
    do {
      let result = try restaurantStore.fetchNearby(center: center, radiusMeters: radius)
      self.restaurants = result
    } catch {
      print("loadNearby error: \(error)")
    }
  }
}

