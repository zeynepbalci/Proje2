import SwiftUI
import MapKit
import RestaurantAIKit

public struct HomeMapView: View {
  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
  )
  public let restaurants: [Restaurant]

  public init(restaurants: [Restaurant]) {
    self.restaurants = restaurants
  }

  public var body: some View {
    Map(coordinateRegion: $region, annotationItems: restaurants.map { MapItem(id: $0.id, name: $0.name, lat: $0.latitude, lon: $0.longitude) }) { item in
      MapMarker(coordinate: CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon), tint: .blue)
    }
    .onAppear {
      if let first = restaurants.first {
        region.center = CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude)
      }
    }
  }

  struct MapItem: Identifiable { let id: UUID; let name: String; let lat: Double; let lon: Double }
}

