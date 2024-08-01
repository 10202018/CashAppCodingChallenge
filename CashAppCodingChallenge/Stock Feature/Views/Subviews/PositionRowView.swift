//
//  PositionRowView.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import SwiftUI

/// Represents a single row item in the portfolio list view.
///
/// This view displays the name of a specific position in a vertical stack (ie: in `ListView`)
struct PositionRowView: View {
  let position: Stock
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(position.name)
        .font(.headline)
        .foregroundStyle(Color.green)
    }
  }
}
