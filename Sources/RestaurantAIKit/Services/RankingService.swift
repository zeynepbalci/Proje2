import Foundation

public struct Weights {
  public let flavor: Double
  public let price: Double
  public let rating: Double
  public let distance: Double
  public init(flavor: Double, price: Double, rating: Double, distance: Double) {
    self.flavor = flavor
    self.price = price
    self.rating = rating
    self.distance = distance
  }
}

public enum RankingService {
  public static func score(flavor: Double, price: Double, rating: Double, distance: Double, weights: Weights) -> Double {
    return flavor * weights.flavor
      + price * weights.price
      + rating * weights.rating
      + distance * weights.distance
  }
}

