import Foundation
import CoreData

public enum DemoDataSeeder {
  public static func seedIfNeeded(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) throws {
    let req = NSFetchRequest<Restaurant>(entityName: "Restaurant")
    req.fetchLimit = 1
    if let count = try? context.count(for: req), count > 0 { return }

    let store = RestaurantStore(context: context)
    let menuStore = MenuStore(context: context)

    let ist = [
      ("Cafe Dessert", 41.0082, 28.9784, 4.6, 2, ["dessert","cafe"], [
        ("Tiramisu", 5500, "dessert", "Hafif, az şekerli", ["light","low_sugar"]),
        ("Brownie", 4500, "dessert", "Yoğun çikolatalı", ["chocolate"])]) ,
      ("Burger Point", 41.0100, 28.9800, 4.2, 2, ["burger","fastfood"], [
        ("Cheeseburger", 9000, "burger", "Klasik", ["beef"])]) ,
      ("Pizza House", 41.0060, 28.9750, 4.4, 3, ["pizza","italian"], [
        ("Margherita", 8500, "pizza", "Domates, mozzarella", ["vegetarian"])])
    ]

    for r in ist {
      let rid = UUID()
      let rest = try store.upsertRestaurant(
        id: rid,
        name: r.0,
        latitude: r.1,
        longitude: r.2,
        rating: r.3,
        priceLevel: Int16(r.4),
        categories: r.5,
        avgPrepMinutes: 20,
        deliveryAvailable: true,
        isOpen: true,
        photoURL: nil
      )
      for m in r.6 {
        _ = try menuStore.upsertMenuItem(
          id: UUID(),
          restaurant: rest,
          name: m.0,
          priceCents: Int32(m.1),
          category: m.2,
          itemDescription: m.3,
          tags: m.4
        )
      }
    }
    if context.hasChanges { try context.save() }
  }
}

