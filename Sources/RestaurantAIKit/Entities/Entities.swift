import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var email: String?
  @NSManaged public var fullName: String?
  @NSManaged public var homeLatitude: Double
  @NSManaged public var homeLongitude: Double
  @NSManaged public var createdAt: Date

  @NSManaged public var preferences: UserPreferences?
  @NSManaged public var weights: UserWeights?
  @NSManaged public var orders: NSSet?
  @NSManaged public var reviews: NSSet?
  @NSManaged public var conversations: NSSet?
  @NSManaged public var favorites: NSSet?
}

@objc(UserPreferences)
public class UserPreferences: NSManagedObject {
  @NSManaged public var prefersCheaper: Bool
  @NSManaged public var prefersFaster: Bool
  @NSManaged public var lovesSweets: Bool
  @NSManaged public var dislikesSpicy: Bool
  @NSManaged public var dietary: [String]?
  @NSManaged public var allergens: [String]?
  @NSManaged public var minBudgetCents: Int32
  @NSManaged public var maxBudgetCents: Int32
  @NSManaged public var cuisineLikes: [String]?
  @NSManaged public var cuisineDislikes: [String]?

  @NSManaged public var user: User
}

@objc(UserWeights)
public class UserWeights: NSManagedObject {
  @NSManaged public var flavorWeight: Double
  @NSManaged public var priceWeight: Double
  @NSManaged public var ratingWeight: Double
  @NSManaged public var distanceWeight: Double

  @NSManaged public var user: User
}

@objc(Restaurant)
public class Restaurant: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var name: String
  @NSManaged public var latitude: Double
  @NSManaged public var longitude: Double
  @NSManaged public var rating: Double
  @NSManaged public var priceLevel: Int16
  @NSManaged public var categories: [String]?
  @NSManaged public var avgPrepMinutes: Int16
  @NSManaged public var deliveryAvailable: Bool
  @NSManaged public var isOpen: Bool
  @NSManaged public var photoURL: String?
  @NSManaged public var createdAt: Date

  @NSManaged public var menus: NSSet?
  @NSManaged public var reviews: NSSet?
  @NSManaged public var orders: NSSet?
  @NSManaged public var providers: NSSet?
  @NSManaged public var favoritedBy: NSSet?
}

@objc(RestaurantProvider)
public class RestaurantProvider: NSManagedObject {
  @NSManaged public var platform: String
  @NSManaged public var platformId: String
  @NSManaged public var url: String?
  @NSManaged public var restaurantId: UUID

  @NSManaged public var restaurant: Restaurant
}

@objc(MenuItem)
public class MenuItem: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var name: String
  @NSManaged public var priceCents: Int32
  @NSManaged public var category: String
  @NSManaged public var itemDescription: String?
  @NSManaged public var tags: [String]?
  @NSManaged public var restaurantId: UUID?

  @NSManaged public var restaurant: Restaurant
  @NSManaged public var orders: NSSet?
}

@objc(Review)
public class Review: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var rating: Int16
  @NSManaged public var comment: String?
  @NSManaged public var createdAt: Date

  @NSManaged public var user: User
  @NSManaged public var restaurant: Restaurant
}

@objc(Order)
public class Order: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var priceCents: Int32
  @NSManaged public var orderedAt: Date

  @NSManaged public var user: User
  @NSManaged public var restaurant: Restaurant
  @NSManaged public var menuItem: MenuItem
}

@objc(Conversation)
public class Conversation: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var startedAt: Date

  @NSManaged public var user: User
  @NSManaged public var messages: NSOrderedSet?
}

@objc(Message)
public class Message: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var role: String
  @NSManaged public var content: String
  @NSManaged public var createdAt: Date
  @NSManaged public var intent: String?
  @NSManaged public var tasteProfile: [String]?

  @NSManaged public var conversation: Conversation
}

@objc(Embedding)
public class Embedding: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var vector: Data
  @NSManaged public var kind: String

  @NSManaged public var refMenuItem: MenuItem?
  @NSManaged public var refMessage: Message?
}

