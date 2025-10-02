import Foundation
import CoreData
import CoreLocation

public final class RestaurantStore {
  private let context: NSManagedObjectContext

  public init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
    self.context = context
  }

  public func upsertRestaurant(
    id: UUID,
    name: String,
    latitude: Double,
    longitude: Double,
    rating: Double?,
    priceLevel: Int16?,
    categories: [String]?,
    avgPrepMinutes: Int16?,
    deliveryAvailable: Bool,
    isOpen: Bool?,
    photoURL: String?
  ) throws -> Restaurant {
    let request = NSFetchRequest<Restaurant>(entityName: "Restaurant")
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.fetchLimit = 1
    let existing = try context.fetch(request).first
    let obj = existing ?? Restaurant(context: context)
    obj.id = id
    obj.name = name
    obj.latitude = latitude
    obj.longitude = longitude
    if let rating { obj.rating = rating }
    if let priceLevel { obj.priceLevel = priceLevel }
    obj.categories = categories
    if let avgPrepMinutes { obj.avgPrepMinutes = avgPrepMinutes }
    obj.deliveryAvailable = deliveryAvailable
    if let isOpen { obj.isOpen = isOpen }
    obj.photoURL = photoURL
    if existing == nil { obj.createdAt = Date() }
    try context.save()
    return obj
  }

  public func fetchNearby(center: CLLocationCoordinate2D, radiusMeters: Double, limit: Int = 50) throws -> [Restaurant] {
    let dLat = radiusMeters / 111_000.0
    let dLon = radiusMeters / (111_000.0 * cos(center.latitude * .pi / 180.0))
    let request = NSFetchRequest<Restaurant>(entityName: "Restaurant")
    request.predicate = NSPredicate(format: "latitude BETWEEN {%f, %f} AND longitude BETWEEN {%f, %f}",
                                    center.latitude - dLat, center.latitude + dLat,
                                    center.longitude - dLon, center.longitude + dLon)
    request.fetchLimit = limit
    request.sortDescriptors = [NSSortDescriptor(key: "rating", ascending: false)]
    return try context.fetch(request)
  }
}

