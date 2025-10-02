import Foundation
import CoreData

public final class ConversationStore {
  private let context: NSManagedObjectContext

  public init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
    self.context = context
  }

  public func startConversation(user: User) throws -> Conversation {
    let c = Conversation(context: context)
    c.id = UUID()
    c.user = user
    c.startedAt = Date()
    try context.save()
    return c
  }

  public func appendMessage(conversation: Conversation, role: String, content: String, intent: String? = nil, tasteProfile: [String]? = nil, createdAt: Date = Date()) throws -> Message {
    let m = Message(context: context)
    m.id = UUID()
    m.conversation = conversation
    m.role = role
    m.content = content
    m.createdAt = createdAt
    m.intent = intent
    m.tasteProfile = tasteProfile
    try context.save()
    return m
  }
}

