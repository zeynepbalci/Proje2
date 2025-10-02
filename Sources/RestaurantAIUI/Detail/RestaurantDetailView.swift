import SwiftUI
import RestaurantAIKit

public struct RestaurantDetailView: View {
  public let restaurant: Restaurant

  public init(restaurant: Restaurant) {
    self.restaurant = restaurant
  }

  public var body: some View {
    List {
      Section(header: Text(restaurant.name)) {
        HStack {
          Text("Puan")
          Spacer()
          Text(String(format: "%.1f", restaurant.rating))
        }
        if restaurant.priceLevel > 0 {
          HStack { Text("Fiyat"); Spacer(); Text(String(repeating: "$", count: Int(restaurant.priceLevel))) }
        }
      }
      if let menus = restaurant.menus as? Set<MenuItem> {
        Section(header: Text("Menü")) {
          ForEach(Array(menus), id: \.id) { item in
            VStack(alignment: .leading) {
              Text(item.name).font(.headline)
              Text(item.itemDescription ?? "").font(.caption).foregroundColor(.secondary)
            }
          }
        }
      }
    }
    .navigationTitle("Detay")
  }
}

struct RestaurantDetailView_Previews: PreviewProvider {
  static var previews: some View {
    Text("Preview requires runtime objects")
  }
}

