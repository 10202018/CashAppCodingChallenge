
//  ContentView.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import SwiftUI

/// `ListView` displays a list of stocks from the portfolio retrieved from the `StockViewModel`.
///
/// This view presents a scrollable list of stocks in the portfolio, each with its name displayed. Tapping on a
/// stock navigates to a detailed view (`DetailView`) where more information is presented.
struct ListView: View {
  @State private var stockViewModel = StockViewModel()
  
  var body: some View {
    NavigationView {
      if !stockViewModel.isLoading {
        List {
          Section(header:
            Text("Stocks")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 8)
          ) {
            ForEach(stockViewModel.stocks) { stock in
              NavigationLink(destination: DetailView(position: stock)) {
                PositionRowView(position: stock)
              }
            }
          }
        }
        .navigationTitle("CashApp iOS Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
        .toolbarBackground(Color.gray, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
      } else {
        LoadingView()
      }
    }
    .alert(isPresented: $stockViewModel.showErrorAlert) {
      Alert(
        title: Text("Error"),
        message: Text(stockViewModel.errorMessage),
        dismissButton: .default(Text("OK"))
      )
    }
  }
}
