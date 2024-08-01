//
//  StockViewModel.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import Observation

/// A view model that manages the stock data for display and interaction in the UI.
@Observable class StockViewModel {
  /// The protocol as a dependency used for retrieving stock information.
  private let stockFetcher: StockFetcher
  
  /// Indicates whether the stock data is currently being fetched.
  ///
  /// This property is `true` while the data is being fetched and is set to `false` when the fetch is
  /// completed (either successfully or with an error). This property is used to display a loading indicator in
  /// ithe UI while the data is being fetched.
  var isLoading = true
  
  /// A boolean flag indicating whether to display an error alert to the user. This property is observed by the
  /// UI and will trigger an alert when set to `true`.
  var showErrorAlert = false
  
  /// A string containing the error message to be displayed in the alert, if applicable.
  var errorMessage = ""
  
  /// The array of stocks associated with the portfolio. Returns an empty array if the stock data has
  /// not been loaded yet.
  var stocks: [Stock] {
    stockFetcher.stocks ?? []
  }

  init(stockFetcher: StockFetcher = RemoteStockFetcher()) {
    self.stockFetcher = stockFetcher
    Task {
      await fetchStocks()
    }
  }

  /// Fetches stock data asynchronously from the data fetcher.
  private func fetchStocks() async {
    do {
      try await stockFetcher.fetchStocks()
      isLoading = false
    } catch let error as RemoteStockFetcher.DataFetcherError {
      handleDataFetcherError(error)
      isLoading = false
    } catch {
      print("Unexpected error: \(error)")
      isLoading = false
    }
  }
  
  /// Handles errors that occur during the data fetching process.
  ///
  /// This method analyzes the specific type of error thrown by the `fetchStocks` method in the
  /// `RemoteStockFetcher` and takes appropriate actions. It updates the `showErrorAlert`
  /// and `errorMessage` properties to display an error message to the user.
  ///
  /// - Parameter error: The `DataFetcherError` thrown by the `fetchStock` method.
  private func handleDataFetcherError(_ error: RemoteStockFetcher.DataFetcherError) {
      switch error {
      case .invalidURL:
          showErrorAlert = true
          errorMessage = "Invalid URL. Please check the API endpoint."
      case .httpError(let statusCode):
          showErrorAlert = true
          errorMessage = "HTTP error: \(statusCode)"
      case .emptyJSONList:
          showErrorAlert = true
          errorMessage = "Empty response. Portfolio contains no stocks."
      case .networkError(let underlyingError):
          showErrorAlert = true
          errorMessage = "Network error: \(underlyingError.localizedDescription)"
      case .decodingError(let underlyingError):
          showErrorAlert = true
        errorMessage = "Error decoding data: \(underlyingError.localizedDescription) Please try again later."
      }
  }
}
