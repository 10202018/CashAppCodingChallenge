//
//  RemoteStockFetcher.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import Foundation
import Observation

/// A class responsible for fetching and managing a portfolio of stocks from the CashApp Stocks API.
///
/// It provides a convenient way to asynchronously retrieve stock information and notify observers when
/// data becomes available or changes.
@Observable public final class RemoteStockFetcher: StockFetcher {
  /// Represents the different error types that can occur during the data fetching process.
  public enum DataFetcherError: Error {
    case invalidURL
    case httpError(Int)
    case emptyJSONList
    case networkError(Error)
    case decodingError(Error)
  }
  
  /// An array of `Stock` objects. This array is initially `nil` and is populated asynchronously when
  /// `fetchStocks` is called.
  public var stocks: [Stock]?
  
  public var session: URLSession
  
  public init(session: URLSession = .shared) {
    self.session = session
  }
  
  /// Asynchronously fetches stock data from the CashApp Stocks API and updates the `stocks` property.
  ///
  /// This method makes a network request to theCashApp Stocks API,  decodes the JSON response into a
  /// `Portfolio` object, and extracts the `stocks` array.
  public func fetchStocks() async throws {
    guard let url = URL(string: "https://storage.googleapis.com/cash-homework/cash-stocks-api/portfolio.json")
    else {
      throw DataFetcherError.invalidURL
    }
    
    do {
      let (data, response) = try await session.data(from: url)
      
      guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode)
      else {
        throw DataFetcherError.httpError(
          (response as? HTTPURLResponse)?.statusCode ?? 500
        )
      }
      
      let decoder = JSONDecoder()
      let portfolio = try decoder.decode(Portfolio.self, from: data)
      if !portfolio.stocks.isEmpty {
        stocks = portfolio.stocks
      } else {
        throw DataFetcherError.emptyJSONList
      }
    } catch let networkError as URLError {
      throw DataFetcherError.networkError(networkError)
    } catch let decodingError as DecodingError {
      throw DataFetcherError.decodingError(decodingError)
    } catch {
      throw error
    }
  }
}
