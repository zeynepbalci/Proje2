import Foundation
import CoreData

public final class OrderStore {
  private let context: NSManagedObjectContext

  public init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
    self.context = context
  }

  public func createOrder(user: User, restaurant: Restaurant, menuItem: MenuItem, priceCents: Int32, orderedAt: Date = Date()) throws -> Order {
    let o = Order(context: context)
    o.id = UUID()
    o.user = user
    o.restaurant = restaurant
    o.menuItem = menuItem
    o.priceCents = priceCents
    o.orderedAt = orderedAt
    try context.save()
    return o
  }

  public func fetchOrders(for user: User, limit: Int = 100) throws -> [Order] {
    let req = NSFetchRequest<Order>(entityName: "Order")
    req.predicate = NSPredicate(format: "user == %@", user)
    req.sortDescriptors = [NSSortDescriptor(key: "orderedAt", ascending: false)]
    req.fetchLimit = limit
    return try context.fetch(req)
  }
}

