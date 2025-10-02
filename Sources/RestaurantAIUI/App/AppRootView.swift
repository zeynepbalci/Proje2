import SwiftUI
import CoreLocation
import RestaurantAIKit

public struct AppRootView: View {
  @State private var selectedTab: Int = 0

  public init() {}

  public var body: some View {
    TabView(selection: $selectedTab) {
      HomeView()
        .tabItem { Label("Keşfet", systemImage: "map") }
        .tag(0)

      ChatView()
        .tabItem { Label("Öneri", systemImage: "sparkles") }
        .tag(1)
    }
  }
}

struct AppRootView_Previews: PreviewProvider {
  static var previews: some View {
    AppRootView()
  }
}

