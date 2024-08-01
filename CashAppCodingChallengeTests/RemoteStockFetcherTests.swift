//
//  CashAppCodingChallengeTests.swift
//  CashAppCodingChallengeTests
//
//  Created by Jah Morris-Jones on 7/23/24.
//
import XCTest
import CashAppCodingChallenge

final class RemoteStockFetcherTests: XCTestCase {
  /// Sample data for testing purposes only.
  struct MockData {
    static let validStockData = """
      {
        "stocks":
          [
            {
              "ticker": "AAPL",
              "name": "AppleInc.",
              "currency": "USD",
              "current_price_cents": 17562,
              "quantity": null,
              "current_price_timestamp": 1681845832
            },
            {
              "ticker":"RUNWAY",
              "name":"Rent The Runway",
              "currency":"USD",
              "current_price_cents":24819,
              "quantity":20,
              "current_price_timestamp":1681845832
            }
          ]
      }
      """.data(using: .utf8)

    static let malformedJsonData = """
      {
        "stocks":
          [
            {
              ticker":"RUNWAY",
              "name":"Rent The Runway",
              "currency":"USD",
              "current_price_cents":24819,
              "quantity":20,
              "current_price_timestamp":1681845832
            }
          ]
      }malformedmalformedmalformed
      """.data(using: .utf8)
    
    static let emptyJsonData = """
      {
        "stocks": []
      }
      """.data(using: .utf8)
  }
  
  func test_fetchStocks_deliversHTTPError_onNon200HTTPResponse() async {
    let sut = makeSUT()
    let samples = [199, 300, 400, 500]
    
    for sample in samples {
      setURLProtocol(data: MockData.validStockData, statusCode: sample)
      
      do {
        try await sut.fetchStocks()
        XCTFail("Expected httpError to be thrown")
      } catch {
        if case RemoteStockFetcher.DataFetcherError.httpError(let error) =
            error {
          XCTAssertEqual(error, sample)
        } else {
          XCTFail("Unexpected error thrown: \(error)")
        }
      }
    }
  }
  
  func test_fetchStocks_deliversDecodingError_on200HTTPResponseWithMalformedJSON() async {
    let sut = makeSUT()
    setURLProtocol(data: MockData.malformedJsonData, statusCode: 200)
    
    do {
      try await sut.fetchStocks()
      XCTFail("Expected decodingError to be thrown")
    } catch {
      if case RemoteStockFetcher.DataFetcherError.decodingError(let error) =
          error {
        XCTAssertEqual(
          error.localizedDescription,
          "The data couldn’t be read because it isn’t in the correct format."
        )
      } else {
        XCTFail("Unexpected error thrown: \(error)")
      }
    }
    
  }
  
  func test_fetchStocks_deliversEmptyJSONListError_on200HTTPResponseWithEmptyJSONList() async {
    let sut = makeSUT()
    setURLProtocol(data: MockData.emptyJsonData, statusCode: 200)
    
    do {
      try await sut.fetchStocks()
      XCTFail("Expected emptyJSONList to be thrown")
    } catch RemoteStockFetcher.DataFetcherError.emptyJSONList {
      // Success: emptyJSONList error returned.
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }
  }
  
  func test_fetchStocks_deliversStocks_On200HTTPResponseWithValidJSON() async {
    let expectedStocksCount = 2
    let sut = makeSUT()
    setURLProtocol(data: MockData.validStockData, statusCode: 200)

    do {
      try await sut.fetchStocks()
      
      let (result1, result2, total) = (
        sut.stocks?[0].ticker,
        sut.stocks?[1].ticker,
        sut.stocks?.count
      )
      
      XCTAssertEqual(result1, "AAPL")
      XCTAssertEqual(result2, "RUNWAY")
      XCTAssertEqual(total, expectedStocksCount)
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }
  }
}

// MARK: - MockURLProtocol

/// Intercepts outgoing requests and alters URL loading behavior.
class MockURLProtocol: URLProtocol {
  /// Maps URLs to test data
  static var mockResponses = [
    URL?: (data: Data?, response: HTTPURLResponse?, error: Error?)
  ]()
  
  /// Sets up a closure to handle requests and provide custom responses
  static var requestHandler: ((URLRequest) throws -> (Data?, HTTPURLResponse))?
  
  /// Sets up a mock session
  static var mockSession: URLSession {
    let config = URLSessionConfiguration.default
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
  }
  
  // MARK: - Required methods
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    if let handler = MockURLProtocol.requestHandler {
      do {
        let (data, response) = try handler(request)
        client?.urlProtocol(
          self,
          didReceive: response,
          cacheStoragePolicy: .notAllowed
        )
        
        if let data = data {
          client?.urlProtocol(self, didLoad: data)
        }
      } catch {
        client?.urlProtocol(self, didFailWithError: error)
      }
    } else if let url = request.url,
              let response = MockURLProtocol.mockResponses[url]?.response {
      client?.urlProtocol(
        self,
        didReceive: response,
        cacheStoragePolicy: .notAllowed
      )
      
      if let data = MockURLProtocol.mockResponses[url]?.data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let error = MockURLProtocol.mockResponses[url]?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
    }
    
    client?.urlProtocolDidFinishLoading(self)
  }
  
  override func stopLoading() {}
}

// MARK: - Helpers

extension RemoteStockFetcherTests {
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RemoteStockFetcher {
    let sut = RemoteStockFetcher(session: MockURLProtocol.mockSession)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }
  
  private func setURLProtocol(data: Data?, statusCode: Int) {
    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      )!
      return (data, response)
    }
  }
}
