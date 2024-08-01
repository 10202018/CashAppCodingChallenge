//
//  Stock.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import Foundation

/// Represents a portfolio of stocks.
public struct Portfolio: Decodable {
  public let stocks: [Stock]
}

/// Represents a stock in a portfolio.
public struct Stock: Decodable, Identifiable {
  /// The ticker symbol for a given stock.
  public let ticker: String
  /// The name of the company to which the ticker belongs.
  public let name: String
  /// The denominating currency.
  public let currency: String
  /// The current trading price for this specific stock in cents (USD).
  public let currentPriceCents: Int
  /// An optional number of shares of this stock in the portfolio.
  public let quantity: Int?
  ///A Unix timestamp represented in UTC from when the current price was last calculated.
  public let  currentPriceTimestamp: Int
  /// The unique, identifiable property of the stock.
  public var id: String {
    return ticker
  }

    enum CodingKeys: String, CodingKey {
        case ticker, name, currency
        case currentPriceCents = "current_price_cents"
        case quantity, currentPriceTimestamp = "current_price_timestamp"
    }
}

extension Stock {
  /// The price of the stock in the locale of the client.
  var formattedCurrentPrice: String {
      let locale = Locale.current
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.locale = locale
      formatter.currencyCode = currency

      let priceInDollars = Double(currentPriceCents) / 100.0
      return formatter.string(from: NSNumber(value: priceInDollars)) ?? "\(priceInDollars)"
  }
  
  /// The localized string representation of the date and time from when the current price was last calculated.
  var currentPriceLocalTime: String {
    let date = Date(timeIntervalSince1970: TimeInterval(currentPriceTimestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .medium
    dateFormatter.locale = Locale.current
    return dateFormatter.string(from: date)
  }
}
