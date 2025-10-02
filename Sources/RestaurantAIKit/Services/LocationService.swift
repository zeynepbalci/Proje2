import Foundation
import CoreLocation

public enum LocationService {
  public static func boundingBox(center: CLLocationCoordinate2D, radiusMeters: Double) -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) {
    let dLat = radiusMeters / 111_000.0
    let dLon = radiusMeters / (111_000.0 * cos(center.latitude * .pi / 180.0))
    return (
      minLat: center.latitude - dLat,
      maxLat: center.latitude + dLat,
      minLon: center.longitude - dLon,
      maxLon: center.longitude + dLon
    )
  }
}

