import Foundation
import CoreLocation
import RestaurantAIKit

@MainActor
public final class ChatViewModel: ObservableObject {
  @Published public var input: String = ""
  @Published public private(set) var suggestions: [RecommendationCandidate] = []

  private let context = PersistentContainer.shared.viewContext
  private let service: RecommendationService

  public init(service: RecommendationService = RecommendationService()) {
    self.service = service
  }

  public func recommendForDemo(center: CLLocationCoordinate2D = .init(latitude: 41.0082, longitude: 28.9784)) {
    // Create or fetch a demo user
    let userStore = UserStore()
    do {
      let user = try userStore.upsertUser(id: UUID(), email: nil, fullName: "Demo", homeLat: center.latitude, homeLon: center.longitude)
      try userStore.ensureDefaults(for: user)
      let results = try service.recommend(for: user, center: center, radiusMeters: 2000, userMessage: input)
      self.suggestions = results
    } catch {
      print("recommend error: \(error)")
    }
  }
}

