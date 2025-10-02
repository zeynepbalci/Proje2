import SwiftUI
import CoreLocation
import RestaurantAIKit

public struct HomeView: View {
  @StateObject private var vm = HomeViewModel()
  @State private var userLocation: CLLocationCoordinate2D = .init(latitude: 41.0082, longitude: 28.9784)

  public init() {}

  public var body: some View {
    NavigationView {
      List(vm.restaurants, id: \.id) { r in
        NavigationLink(destination: RestaurantDetailView(restaurant: r)) {
          VStack(alignment: .leading, spacing: 4) {
            Text(r.name).font(.headline)
            HStack(spacing: 12) {
              Text("⭐️ \(String(format: "%.1f", r.rating))")
              if r.priceLevel > 0 { Text(String(repeating: "$", count: Int(r.priceLevel))) }
            }.font(.subheadline).foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("Yakındakiler")
      .onAppear {
        vm.center = userLocation
        vm.loadNearby()
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}

