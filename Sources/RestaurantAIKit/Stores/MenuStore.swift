import Foundation
import CoreData

public final class MenuStore {
  private let context: NSManagedObjectContext

  public init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
    self.context = context
  }

  public func upsertMenuItem(
    id: UUID,
    restaurant: Restaurant,
    name: String,
    priceCents: Int32,
    category: String,
    itemDescription: String?,
    tags: [String]?
  ) throws -> MenuItem {
    let request = NSFetchRequest<MenuItem>(entityName: "MenuItem")
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.fetchLimit = 1
    let existing = try context.fetch(request).first
    let obj = existing ?? MenuItem(context: context)
    obj.id = id
    obj.restaurant = restaurant
    obj.name = name
    obj.priceCents = priceCents
    obj.category = category
    obj.itemDescription = itemDescription
    obj.tags = tags
    try context.save()
    return obj
  }

  public func fetchByRestaurant(_ restaurant: Restaurant) throws -> [MenuItem] {
    let request = NSFetchRequest<MenuItem>(entityName: "MenuItem")
    request.predicate = NSPredicate(format: "restaurant == %@", restaurant)
    request.sortDescriptors = [NSSortDescriptor(key: "priceCents", ascending: true)]
    return try context.fetch(request)
  }
}

