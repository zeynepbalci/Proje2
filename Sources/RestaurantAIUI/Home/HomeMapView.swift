import SwiftUI
import MapKit
import RestaurantAIKit

public struct HomeMapView: View {
  @State private var position: MapCameraPosition = .automatic
  public let restaurants: [Restaurant]

  public init(restaurants: [Restaurant]) {
    self.restaurants = restaurants
  }

  public var body: some View {
    Map(position: $position) {
      ForEach(restaurants, id: \.id) { r in
        let coord = CLLocationCoordinate2D(latitude: r.latitude, longitude: r.longitude)
        Annotation(r.name, coordinate: coord) {
          ZStack {
            Circle().fill(Color.blue.opacity(0.8)).frame(width: 12, height: 12)
            Circle().stroke(Color.white, lineWidth: 2).frame(width: 12, height: 12)
          }
        }
      }
    }
    .onAppear {
      if let first = restaurants.first {
        position = .region(MKCoordinateRegion(center: .init(latitude: first.latitude, longitude: first.longitude), span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)))
      }
    }
  }
}

