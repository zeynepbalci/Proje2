import Foundation
#if canImport(CoreData)
import CoreData

enum CoreDataModelBuilder {
  static func buildModel() -> NSManagedObjectModel {
    let model = NSManagedObjectModel()

    // MARK: - Entities
    let user = NSEntityDescription()
    user.name = "User"
    user.managedObjectClassName = "RestaurantAIKit.User"

    let userPreferences = NSEntityDescription()
    userPreferences.name = "UserPreferences"
    userPreferences.managedObjectClassName = "RestaurantAIKit.UserPreferences"

    let userWeights = NSEntityDescription()
    userWeights.name = "UserWeights"
    userWeights.managedObjectClassName = "RestaurantAIKit.UserWeights"

    let restaurant = NSEntityDescription()
    restaurant.name = "Restaurant"
    restaurant.managedObjectClassName = "RestaurantAIKit.Restaurant"

    let restaurantProvider = NSEntityDescription()
    restaurantProvider.name = "RestaurantProvider"
    restaurantProvider.managedObjectClassName = "RestaurantAIKit.RestaurantProvider"

    let menuItem = NSEntityDescription()
    menuItem.name = "MenuItem"
    menuItem.managedObjectClassName = "RestaurantAIKit.MenuItem"

    let review = NSEntityDescription()
    review.name = "Review"
    review.managedObjectClassName = "RestaurantAIKit.Review"

    let order = NSEntityDescription()
    order.name = "Order"
    order.managedObjectClassName = "RestaurantAIKit.Order"

    let conversation = NSEntityDescription()
    conversation.name = "Conversation"
    conversation.managedObjectClassName = "RestaurantAIKit.Conversation"

    let message = NSEntityDescription()
    message.name = "Message"
    message.managedObjectClassName = "RestaurantAIKit.Message"

    let embedding = NSEntityDescription()
    embedding.name = "Embedding"
    embedding.managedObjectClassName = "RestaurantAIKit.Embedding"

    // MARK: - Attributes
    func attr(_ name: String, _ type: NSAttributeType, optional: Bool = true) -> NSAttributeDescription {
      let a = NSAttributeDescription()
      a.name = name
      a.attributeType = type
      a.isOptional = optional
      a.isTransient = false
      return a
    }

    func transformable(_ name: String, optional: Bool = true) -> NSAttributeDescription {
      let a = NSAttributeDescription()
      a.name = name
      a.attributeType = .transformableAttributeType
      a.isOptional = optional
      a.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName
      a.allowsExternalBinaryDataStorage = false
      return a
    }

    // User
    user.properties = [
      attr("id", .UUIDAttributeType, optional: false),
      attr("email", .stringAttributeType),
      attr("fullName", .stringAttributeType),
      attr("homeLatitude", .doubleAttributeType),
      attr("homeLongitude", .doubleAttributeType),
      attr("createdAt", .dateAttributeType, optional: false)
    ]

    // UserPreferences
    userPreferences.properties = [
      attr("prefersCheaper", .booleanAttributeType, optional: false),
      attr("prefersFaster", .booleanAttributeType, optional: false),
      attr("lovesSweets", .booleanAttributeType, optional: false),
      attr("dislikesSpicy", .booleanAttributeType, optional: false),
      transformable("dietary"),
      transformable("allergens"),
      attr("minBudgetCents", .integer32AttributeType),
      attr("maxBudgetCents", .integer32AttributeType),
      transformable("cuisineLikes"),
      transformable("cuisineDislikes")
    ]

    // UserWeights
    userWeights.properties = [
      attr("flavorWeight", .doubleAttributeType, optional: false),
      attr("priceWeight", .doubleAttributeType, optional: false),
      attr("ratingWeight", .doubleAttributeType, optional: false),
      attr("distanceWeight", .doubleAttributeType, optional: false)
    ]

    // Restaurant
    restaurant.properties = [
      attr("id", .UUIDAttributeType, optional: false),
      attr("name", .stringAttributeType, optional: false),
      attr("latitude", .doubleAttributeType, optional: false),
      attr("longitude", .doubleAttributeType, optional: false),
      attr("rating", .doubleAttributeType),
      attr("priceLevel", .integer16AttributeType),
      transformable("categories"),
      attr("avgPrepMinutes", .integer16AttributeType),
      attr("deliveryAvailable", .booleanAttributeType, optional: false),
      attr("isOpen", .booleanAttributeType),
      attr("photoURL", .stringAttributeType),
      attr("createdAt", .dateAttributeType, optional: false)
    ]

    // RestaurantProvider
    restaurantProvider.properties = [
      attr("platform", .stringAttributeType, optional: false),
      attr("platformId", .stringAttributeType, optional: false),
      attr("url", .stringAttributeType),
      // for uniqueness on provider level
      attr("restaurantId", .UUIDAttributeType, optional: false)
    ]

    // MenuItem
    menuItem.properties = [
      attr("id", .UUIDAttributeType, optional: false),
      attr("name", .stringAttributeType, optional: false),
      attr("priceCents", .integer32AttributeType, optional: false),
      attr("category", .stringAttributeType, optional: false),
      attr("itemDescription", .stringAttributeType),
      transformable("tags"),
      attr("restaurantId", .UUIDAttributeType)
    ]

    // Review
    review.properties = [
      attr("id", .UUIDAttributeType, optional: false),
      attr("rating", .integer16AttributeType, optional: false),
      attr("comment", .stringAttributeType),
      attr("createdAt", .dateAttributeType, optional: false)
    ]

    // Order
    order.properties = [
      attr("id", .UUIDAttributeType, optional: false),
      attr("priceCents", .integer32AttributeType, optional: false),
      attr("orderedAt", .dateAttributeType, optional: false)
    ]

    // Conversation
    conversation.properties = [
      attr("id", .UUIDAttributeType, optional: false),
      attr("startedAt", .dateAttributeType, optional: false)
    ]

    // Message
    message.properties = [
      attr("id", .UUIDAttributeType, optional: false),
      attr("role", .stringAttributeType, optional: false),
      attr("content", .stringAttributeType, optional: false),
      attr("createdAt", .dateAttributeType, optional: false),
      attr("intent", .stringAttributeType),
      transformable("tasteProfile")
    ]

    // Embedding
    embedding.properties = [
      attr("id", .UUIDAttributeType, optional: false),
      transformable("vector", optional: false),
      attr("kind", .stringAttributeType, optional: false)
    ]

    // MARK: - Relationships
    func toOne(name: String, destination: NSEntityDescription, inverse: String, deleteRule: NSDeleteRule = .nullifyDeleteRule, optional: Bool = true) -> NSRelationshipDescription {
      let r = NSRelationshipDescription()
      r.name = name
      r.destinationEntity = destination
      r.minCount = optional ? 0 : 1
      r.maxCount = 1
      r.deleteRule = deleteRule
      r.isOptional = optional
      return r
    }

    func toMany(name: String, destination: NSEntityDescription, inverse: String, deleteRule: NSDeleteRule = .nullifyDeleteRule, ordered: Bool = false) -> NSRelationshipDescription {
      let r = NSRelationshipDescription()
      r.name = name
      r.destinationEntity = destination
      r.minCount = 0
      r.maxCount = 0 // 0 means undefined, i.e., to-many
      r.deleteRule = deleteRule
      r.isOrdered = ordered
      return r
    }

    // Define relationships and set inverses after creation
    let user_preferences = toOne(name: "preferences", destination: userPreferences, inverse: "user", deleteRule: .cascadeDeleteRule)
    let user_weightsRel = toOne(name: "weights", destination: userWeights, inverse: "user", deleteRule: .cascadeDeleteRule)
    let user_orders = toMany(name: "orders", destination: order, inverse: "user", deleteRule: .cascadeDeleteRule)
    let user_reviews = toMany(name: "reviews", destination: review, inverse: "user", deleteRule: .cascadeDeleteRule)
    let user_conversations = toMany(name: "conversations", destination: conversation, inverse: "user", deleteRule: .cascadeDeleteRule)
    let user_favorites = toMany(name: "favorites", destination: restaurant, inverse: "favoritedBy")

    let pref_user = toOne(name: "user", destination: user, inverse: "preferences", deleteRule: .nullifyDeleteRule, optional: false)
    let weights_user = toOne(name: "user", destination: user, inverse: "weights", deleteRule: .nullifyDeleteRule, optional: false)

    let restaurant_menus = toMany(name: "menus", destination: menuItem, inverse: "restaurant", deleteRule: .cascadeDeleteRule)
    let restaurant_reviews = toMany(name: "reviews", destination: review, inverse: "restaurant", deleteRule: .cascadeDeleteRule)
    let restaurant_orders = toMany(name: "orders", destination: order, inverse: "restaurant", deleteRule: .cascadeDeleteRule)
    let restaurant_providersRel = toMany(name: "providers", destination: restaurantProvider, inverse: "restaurant", deleteRule: .cascadeDeleteRule)
    let restaurant_favoritedBy = toMany(name: "favoritedBy", destination: user, inverse: "favorites")

    let provider_restaurant = toOne(name: "restaurant", destination: restaurant, inverse: "providers", deleteRule: .nullifyDeleteRule, optional: false)

    let menu_restaurant = toOne(name: "restaurant", destination: restaurant, inverse: "menus", deleteRule: .nullifyDeleteRule, optional: false)
    let menu_orders = toMany(name: "orders", destination: order, inverse: "menuItem", deleteRule: .cascadeDeleteRule)

    let review_user = toOne(name: "user", destination: user, inverse: "reviews", deleteRule: .nullifyDeleteRule, optional: false)
    let review_restaurant = toOne(name: "restaurant", destination: restaurant, inverse: "reviews", deleteRule: .nullifyDeleteRule, optional: false)

    let order_user = toOne(name: "user", destination: user, inverse: "orders", deleteRule: .nullifyDeleteRule, optional: false)
    let order_restaurant = toOne(name: "restaurant", destination: restaurant, inverse: "orders", deleteRule: .nullifyDeleteRule, optional: false)
    let order_menu = toOne(name: "menuItem", destination: menuItem, inverse: "orders", deleteRule: .nullifyDeleteRule, optional: false)

    let conv_user = toOne(name: "user", destination: user, inverse: "conversations", deleteRule: .nullifyDeleteRule, optional: false)
    let conv_messages = toMany(name: "messages", destination: message, inverse: "conversation", deleteRule: .cascadeDeleteRule, ordered: true)

    let msg_conversation = toOne(name: "conversation", destination: conversation, inverse: "messages", deleteRule: .nullifyDeleteRule, optional: false)

    let emb_menu = toOne(name: "refMenuItem", destination: menuItem, inverse: "embedding", deleteRule: .cascadeDeleteRule)
    let emb_msg = toOne(name: "refMessage", destination: message, inverse: "embedding", deleteRule: .cascadeDeleteRule)

    // Attach relationships to entities
    user.properties += [user_preferences, user_weightsRel, user_orders, user_reviews, user_conversations, user_favorites]
    userPreferences.properties += [pref_user]
    userWeights.properties += [weights_user]
    restaurant.properties += [restaurant_menus, restaurant_reviews, restaurant_orders, restaurant_providersRel, restaurant_favoritedBy]
    restaurantProvider.properties += [provider_restaurant]
    menuItem.properties += [menu_restaurant, menu_orders]
    review.properties += [review_user, review_restaurant]
    order.properties += [order_user, order_restaurant, order_menu]
    conversation.properties += [conv_user, conv_messages]
    message.properties += [msg_conversation]
    embedding.properties += [emb_menu, emb_msg]

    // Inverses
    user_preferences.inverseRelationship = pref_user
    pref_user.inverseRelationship = user_preferences

    user_weightsRel.inverseRelationship = weights_user
    weights_user.inverseRelationship = user_weightsRel

    user_orders.inverseRelationship = order_user
    order_user.inverseRelationship = user_orders

    user_reviews.inverseRelationship = review_user
    review_user.inverseRelationship = user_reviews

    user_conversations.inverseRelationship = conv_user
    conv_user.inverseRelationship = user_conversations

    user_favorites.inverseRelationship = restaurant_favoritedBy
    restaurant_favoritedBy.inverseRelationship = user_favorites

    restaurant_menus.inverseRelationship = menu_restaurant
    menu_restaurant.inverseRelationship = restaurant_menus

    restaurant_reviews.inverseRelationship = review_restaurant
    review_restaurant.inverseRelationship = restaurant_reviews

    restaurant_orders.inverseRelationship = order_restaurant
    order_restaurant.inverseRelationship = restaurant_orders

    restaurant_providersRel.inverseRelationship = provider_restaurant
    provider_restaurant.inverseRelationship = restaurant_providersRel

    menu_orders.inverseRelationship = order_menu
    order_menu.inverseRelationship = menu_orders

    conv_messages.inverseRelationship = msg_conversation
    msg_conversation.inverseRelationship = conv_messages

    emb_menu.inverseRelationship = nil // one-way from embedding to menu
    emb_msg.inverseRelationship = nil

    model.entities = [
      user,
      userPreferences,
      userWeights,
      restaurant,
      restaurantProvider,
      menuItem,
      review,
      order,
      conversation,
      message,
      embedding
    ]

    return model
  }
}
#else
enum CoreDataModelBuilder {
  static func buildModel() -> AnyObject { fatalError("CoreData not available on this platform") }
}
#endif

