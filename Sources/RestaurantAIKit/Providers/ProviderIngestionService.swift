import Foundation
import CoreData
import CoreLocation

public final class ProviderIngestionService {
  private let context: NSManagedObjectContext
  private let restaurantStore: RestaurantStore
  private let menuStore: MenuStore

  public init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
    self.context = context
    self.restaurantStore = RestaurantStore(context: context)
    self.menuStore = MenuStore(context: context)
  }

  public func ingest(api: RestaurantProviderAPI, platform: String, center: CLLocationCoordinate2D, radiusMeters: Double, limit: Int = 30) async throws {
    let restaurants = try await api.searchNearby(center: center, radiusMeters: radiusMeters, limit: limit)
    for dto in restaurants {
      let rid = UUID()
      let r = try restaurantStore.upsertRestaurant(
        id: rid,
        name: dto.name,
        latitude: dto.latitude,
        longitude: dto.longitude,
        rating: dto.rating,
        priceLevel: dto.priceLevel.map(Int16.init),
        categories: dto.categories,
        avgPrepMinutes: nil,
        deliveryAvailable: true,
        isOpen: dto.isOpen,
        photoURL: dto.photoURL
      )

      let provider = RestaurantProvider(context: context)
      provider.platform = platform
      provider.platformId = dto.externalId
      provider.url = nil
      provider.restaurant = r
      provider.restaurantId = r.id

      let menu = try await api.fetchMenu(for: dto.externalId)
      for item in menu {
        _ = try menuStore.upsertMenuItem(
          id: UUID(),
          restaurant: r,
          name: item.name,
          priceCents: Int32(item.priceCents),
          category: item.category,
          itemDescription: item.description,
          tags: item.tags
        )
      }
    }
    if context.hasChanges { try context.save() }
  }
}

