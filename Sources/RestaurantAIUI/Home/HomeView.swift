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
          RestaurantRow(restaurant: r)
        }
      }
      .navigationTitle("Yakındakiler")
      .onAppear {
        vm.center = userLocation
        vm.loadNearby()
      }
      .toolbar {
        if let key = ProcessInfo.processInfo.environment["GOOGLE_PLACES_API_KEY"], !key.isEmpty {
          Button {
            Task { await vm.syncFromGoogle(apiKey: key) }
          } label: {
            Label("Google'dan Çek", systemImage: "arrow.down.circle")
          }
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}

