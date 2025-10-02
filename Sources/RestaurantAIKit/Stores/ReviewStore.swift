import Foundation
import CoreData

public final class ReviewStore {
  private let context: NSManagedObjectContext

  public init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
    self.context = context
  }

  public func addReview(user: User, restaurant: Restaurant, rating: Int16, comment: String?, createdAt: Date = Date()) throws -> Review {
    let r = Review(context: context)
    r.id = UUID()
    r.user = user
    r.restaurant = restaurant
    r.rating = rating
    r.comment = comment
    r.createdAt = createdAt
    try context.save()
    return r
  }

  public func fetchForRestaurant(_ restaurant: Restaurant, limit: Int = 50) throws -> [Review] {
    let req = NSFetchRequest<Review>(entityName: "Review")
    req.predicate = NSPredicate(format: "restaurant == %@", restaurant)
    req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    req.fetchLimit = limit
    return try context.fetch(req)
  }
}

