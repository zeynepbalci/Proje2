import Foundation
import CoreLocation

public final class GooglePlacesProvider: RestaurantProviderAPI {
  private let apiKey: String
  private let session: URLSession

  public init(apiKey: String, session: URLSession = .shared) {
    self.apiKey = apiKey
    self.session = session
  }

  public func searchNearby(center: CLLocationCoordinate2D, radiusMeters: Double, limit: Int) async throws -> [ProviderRestaurantDTO] {
    let clampedRadius = max(1.0, min(50_000.0, radiusMeters))
    var comps = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")!
    comps.queryItems = [
      URLQueryItem(name: "location", value: "\(center.latitude),\(center.longitude)"),
      URLQueryItem(name: "radius", value: String(Int(clampedRadius))),
      URLQueryItem(name: "type", value: "restaurant"),
      URLQueryItem(name: "key", value: apiKey)
    ]
    let url = comps.url!
    let (data, resp) = try await session.data(from: url)
    guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
      throw NSError(domain: "GooglePlacesProvider", code: (resp as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? ""]) }

    let decoded = try JSONDecoder().decode(NearbyResponse.self, from: data)
    let results = decoded.results.prefix(limit)
    return try await withThrowingTaskGroup(of: ProviderRestaurantDTO.self) { group in
      for r in results {
        group.addTask {
          let details = try await self.fetchDetails(placeId: r.place_id)
          let website = details?.result?.website
          let photoURL: String? = {
            guard let ref = r.photos?.first?.photo_reference else { return nil }
            var c = URLComponents(string: "https://maps.googleapis.com/maps/api/place/photo")!
            c.queryItems = [
              URLQueryItem(name: "maxwidth", value: "400"),
              URLQueryItem(name: "photo_reference", value: ref),
              URLQueryItem(name: "key", value: self.apiKey)
            ]
            return c.url?.absoluteString
          }()

          return ProviderRestaurantDTO(
            externalId: r.place_id,
            name: r.name,
            latitude: r.geometry.location.lat,
            longitude: r.geometry.location.lng,
            rating: r.rating,
            priceLevel: r.price_level,
            categories: r.types,
            isOpen: r.opening_hours?.open_now,
            photoURL: photoURL,
            websiteURL: website
          )
        }
      }
      var out: [ProviderRestaurantDTO] = []
      for try await dto in group { out.append(dto) }
      return out
    }
  }

  public func fetchMenu(for externalRestaurantId: String) async throws -> [ProviderMenuItemDTO] {
    guard let details = try await fetchDetails(placeId: externalRestaurantId), let website = details.result?.website else { return [] }
    return try await WebMenuParser.fetchAndParseMenu(from: website)
  }

  private func fetchDetails(placeId: String) async throws -> DetailsResponse? {
    var comps = URLComponents(string: "https://maps.googleapis.com/maps/api/place/details/json")!
    comps.queryItems = [
      URLQueryItem(name: "place_id", value: placeId),
      URLQueryItem(name: "fields", value: "website,url,international_phone_number,opening_hours"),
      URLQueryItem(name: "key", value: apiKey)
    ]
    let url = comps.url!
    let (data, resp) = try await session.data(from: url)
    guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else { return nil }
    return try JSONDecoder().decode(DetailsResponse.self, from: data)
  }
}

// MARK: - Decoding

private struct NearbyResponse: Decodable {
  let results: [PlaceResult]
}

private struct PlaceResult: Decodable {
  let place_id: String
  let name: String
  let geometry: Geometry
  let rating: Double?
  let price_level: Int?
  let opening_hours: OpeningHours?
  let photos: [Photo]?
  let types: [String]?
}

private struct Geometry: Decodable { let location: GeoLocation }
private struct GeoLocation: Decodable { let lat: Double; let lng: Double }
private struct OpeningHours: Decodable { let open_now: Bool? }
private struct Photo: Decodable { let photo_reference: String }

private struct DetailsResponse: Decodable { let result: DetailsResult? }
private struct DetailsResult: Decodable { let website: String? }

