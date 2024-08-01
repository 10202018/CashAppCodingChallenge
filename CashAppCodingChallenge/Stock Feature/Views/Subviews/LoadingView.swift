//
//  LoadingView.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import SwiftUI

/// A view to display a loading indicator while fetching data.
///
/// This view shows a progress view (spinner) to indicate that data is being retrieved.
struct LoadingView: View {
  var body: some View {
    ProgressView()
      .controlSize(.large)
  }
}
