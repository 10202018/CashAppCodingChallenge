//
//  StockFetcher.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import Foundation

/// A contract that defines the interface for fetching stock data.
public protocol StockFetcher {
    typealias Result = Swift.Result<[Stock], Error>
  
  /// Fetches an array of stocks.
  func fetchStocks() async throws
  
  /// A list of the most recently fetched stocks, or `nil` if not yet fetched or if an error occurred.
  var stocks: [Stock]? { get }
}
