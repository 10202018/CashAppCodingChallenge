//
//  DetailView.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import SwiftUI

/// A view that displays detailed information about a specific position.
struct DetailView: View {
  /// The environment's color scheme (light or dark mode).
  @Environment(\.colorScheme) var colorScheme
  
  /// The position containing the data to display.
  let position: Stock
  
  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      Text(position.name)
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .center)

      LabelValueView(label: "Ticker:", value: position.ticker)
      LabelValueView(label: "Price:", value: String(position.formattedCurrentPrice))
      LabelValueView(label: "Time:", value: String(position.currentPriceLocalTime))
      LabelValueView(
        label: "Amount held:",
        value: position.quantity.map {
          !position.ticker.hasPrefix("^") ? String($0) : "n/a"
        } ?? "n/a")
      
      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .multilineTextAlignment(.center)
    .padding()
    .foregroundColor(colorScheme == .dark ? Color.green : Color.green)
    .background(colorScheme == .dark ? Color.black : Color.white)
  }
}
