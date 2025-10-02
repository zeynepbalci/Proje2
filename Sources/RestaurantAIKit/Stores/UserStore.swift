import Foundation
import CoreData

public final class UserStore {
  private let context: NSManagedObjectContext

  public init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
    self.context = context
  }

  public func upsertUser(id: UUID, email: String?, fullName: String?, homeLat: Double?, homeLon: Double?) throws -> User {
    let req = NSFetchRequest<User>(entityName: "User")
    req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    req.fetchLimit = 1
    let existing = try context.fetch(req).first
    let u = existing ?? User(context: context)
    u.id = id
    u.email = email
    u.fullName = fullName
    if let homeLat { u.homeLatitude = homeLat }
    if let homeLon { u.homeLongitude = homeLon }
    if existing == nil { u.createdAt = Date() }
    try context.save()
    return u
  }

  public func ensureDefaults(for user: User) throws {
    if user.preferences == nil {
      let p = UserPreferences(context: context)
      p.user = user
      p.prefersCheaper = false
      p.prefersFaster = false
      p.lovesSweets = false
      p.dislikesSpicy = false
      user.preferences = p
    }
    if user.weights == nil {
      let w = UserWeights(context: context)
      w.user = user
      w.flavorWeight = 0.4
      w.priceWeight = 0.25
      w.ratingWeight = 0.2
      w.distanceWeight = 0.15
      user.weights = w
    }
    try context.save()
  }
}

