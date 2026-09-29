//
//  MockCache.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 28.09.2026.
//

import Foundation

final class MockCache: CurrencyCacheProtocol {
    var cachedCurrencies: [CurrencyModel]?
    var cachedDate: Date?
    
    var lastFetchDate: Date? {
        cachedDate
    }
    
    func loadCurrencies() -> [CurrencyModel]? {
        cachedCurrencies
    }
    
    func saveCurrencies(_ currencies: [CurrencyModel], date: Date) {
        cachedCurrencies = currencies
        cachedDate = date
    }
}
