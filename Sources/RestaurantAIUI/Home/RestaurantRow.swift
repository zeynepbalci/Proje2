import SwiftUI
import RestaurantAIKit

struct RestaurantRow: View {
  let restaurant: Restaurant

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.gray.opacity(0.2))
        .frame(width: 64, height: 64)
        .overlay(Text(restaurant.name.prefix(1)).font(.headline))

      VStack(alignment: .leading, spacing: 6) {
        Text(restaurant.name)
          .font(.headline)
        HStack(spacing: 8) {
          Label(String(format: "%.1f", restaurant.rating), systemImage: "star.fill")
            .foregroundColor(.yellow)
            .font(.caption)
          if restaurant.priceLevel > 0 {
            Text(String(repeating: "$", count: Int(restaurant.priceLevel)))
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        if let categories = restaurant.categories, !categories.isEmpty {
          Text(categories.joined(separator: " • "))
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(1)
        }
      }
      Spacer()
    }
    .padding(.vertical, 8)
  }
}

