//
//  Currency_converterTests.swift
//  Currency converterTests
//
//  Created by Daniel Husiuk on 15.09.2026.
//

import XCTest
@testable import Currency_converter

final class CurrencyConverterTests: XCTestCase {
    
    private var service: CurrencyServiceProtocol?
    private let mockApiManager = MockApiManager()
    private let mockCache = MockCache()
    
    override func setUpWithError() throws {
        service = CurrencyService(apiManager: mockApiManager, cachedCurrency: mockCache)
    }
    
    func testFetchCurrencyService() async throws {
        let result = await service?.fetchCurrencyService()
        
        XCTAssertEqual(result?.currencies.count, 3)
        XCTAssertEqual(result?.currencies[0].code, "GBP")
        XCTAssertEqual(result?.currencies[1].code, "EUR")
        XCTAssertEqual(result?.currencies[2].code, "UAH")
    }
    
    func testCurrencyService_AddUSD() async throws {
        mockApiManager.result = .success([
            CurrencyResponse(
                r030: 840,
                name: "Доллар США",
                rate: 45.000,
                code: "USD",
                exchangeDate: "28.09.2026")
        ])
        let result = await service?.fetchCurrencyService()
        
        XCTAssertEqual(result?.currencies.count, 2)
        XCTAssertEqual(result?.currencies[0].code, "USD")
        XCTAssertEqual(result?.currencies[0].name, "Доллар США")
        XCTAssertEqual(result?.currencies[1].code, "UAH")
        XCTAssertEqual(result?.currencies[1].price, 1.000)
    }
    
    func testCurrencyCache_UsesCache() async throws {
        let cachedCurrencies = [CurrencyModel(code: "USD", name: "Долар США", price: 45.000)]
        mockCache.cachedCurrencies = cachedCurrencies
        mockCache.cachedDate = Date()
        
        let result = await service?.fetchCurrencyService()
        XCTAssertEqual(result?.currencies.count, 1)
        XCTAssertEqual(result?.currencies.first?.code, "USD")
        XCTAssertEqual(result?.currencies.first?.price, 45.000)
    }
    
    func testCurrencyCache_SavesCache() async throws {
        mockApiManager.result = .success([
            CurrencyResponse(
                r030: 840,
                name: "Доллар США",
                rate: 45.000,
                code: "USD",
                exchangeDate: "28.09.2026")
        ])
        _ = await service?.fetchCurrencyService()
        
        XCTAssertEqual(mockCache.cachedCurrencies?.count, 2)
        XCTAssertEqual(mockCache.cachedCurrencies?[0].code, "USD")
        XCTAssertEqual(mockCache.cachedCurrencies?[1].code, "UAH")
        XCTAssertNotNil(mockCache.cachedDate)
    }
    
    func testCurrencyCache_LoadCacheWhenApiFails() async throws {
        let cachedCurrencies = [CurrencyModel(code: "USD", name: "Долар США", price: 45.000)]
        mockCache.cachedCurrencies = cachedCurrencies
        mockCache.cachedDate = Date().addingTimeInterval(-2 * 60 * 60)
        mockApiManager.result = .failure(DataError.invalidResponse)
        
        let result = await service?.fetchCurrencyService()
        XCTAssertEqual(result?.currencies.count, 1)
        XCTAssertEqual(result?.currencies.first?.code, "USD")
        XCTAssertEqual(result?.currencies.first?.price, 45.000)
    }
    
    func testConvertCurrency() throws {
        let converter = CurrencyConverter(multiplier: 1)
        
        let usd = CurrencyModel(code: "USD", name: "Долар США", price: 45.000)
        let eur = CurrencyModel(code: "EUR", name: "Євро", price: 50.000)
        let result = converter.convertCurrency(amount: 100, from: usd, to: eur)
        XCTAssertEqual(result, 90)
    }
    
    func testPerformanceExample() throws {
        self.measure {
        }
    }
    
}
