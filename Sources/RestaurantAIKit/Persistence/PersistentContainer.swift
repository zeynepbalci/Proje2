import Foundation
import CoreData

public final class PersistentContainer {
  public static let shared = PersistentContainer()

  public let container: NSPersistentContainer

  public var viewContext: NSManagedObjectContext { container.viewContext }

  private init(inMemory: Bool = false) {
    let model = CoreDataModelBuilder.buildModel()
    container = NSPersistentContainer(name: "RestaurantAIModel", managedObjectModel: model)
    if inMemory {
      let description = NSPersistentStoreDescription()
      description.type = NSInMemoryStoreType
      container.persistentStoreDescriptions = [description]
    }
    container.loadPersistentStores { _, error in
      if let error = error {
        fatalError("Unresolved error: \(error)")
      }
    }
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
}

