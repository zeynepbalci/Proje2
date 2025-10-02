import SwiftUI
import CoreLocation
import RestaurantAIKit

public struct AppRootView: View {
  @State private var selectedTab: Int = 0

  public init() {}

  public var body: some View {
    TabView(selection: $selectedTab) {
      NavigationView { HomeView() }
        .tabItem { Label("Keşfet", systemImage: "list.bullet") }
        .tag(0)

      NavigationView { ChatView() }
        .tabItem { Label("Öneri", systemImage: "sparkles") }
        .tag(1)
    }
    .task {
      try? DemoDataSeeder.seedIfNeeded()
    }
  }
}

struct AppRootView_Previews: PreviewProvider {
  static var previews: some View {
    AppRootView()
  }
}

