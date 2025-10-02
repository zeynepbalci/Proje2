import SwiftUI
import CoreLocation
import RestaurantAIKit

public struct ChatView: View {
  @StateObject private var vm = ChatViewModel()
  @State private var center: CLLocationCoordinate2D = .init(latitude: 41.0082, longitude: 28.9784)

  public init() {}

  public var body: some View {
    VStack(spacing: 12) {
      HStack {
        TextField("Ne canın çekiyor? örn: hafif çikolatalı tatlı", text: $vm.input)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        Button("Öner") { vm.recommendForDemo(center: center) }
          .buttonStyle(.borderedProminent)
      }
      .padding(.horizontal)

      List(vm.suggestions, id: \.menuItem.id) { item in
        VStack(alignment: .leading, spacing: 4) {
          Text(item.menuItem.name).font(.headline)
          Text(item.restaurant.name).font(.subheadline)
          Text(String(format: "Skor: %.2f", item.score)).font(.caption).foregroundColor(.secondary)
          Text(item.reason).font(.caption2).foregroundColor(.secondary)
        }
      }
    }
    .navigationTitle("AI Öneri")
  }
}

struct ChatView_Previews: PreviewProvider {
  static var previews: some View {
    ChatView()
  }
}

