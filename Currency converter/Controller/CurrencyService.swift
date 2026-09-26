//
//  CurrencyService.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 22.09.2026.
//

import Foundation

protocol CurrencyServiceProtocol {
    func fetchCurrencyService() async -> (currencies: [CurrencyModel], date: Date)?
}

final class CurrencyService: CurrencyServiceProtocol {
    private let apiManager: ApiManagerProtocol
    private let cachedCurrency: CurrencyCache
    private let refreshTimeInterval: TimeInterval = 60 * 60
    
    init(apiManager: ApiManagerProtocol, cachedCurrency: CurrencyCache = CurrencyCache()) {
        self.apiManager = apiManager
        self.cachedCurrency = cachedCurrency
    }
    
    func fetchCurrencyService() async -> (currencies: [CurrencyModel], date: Date)? {
        if let lastFetchDate = cachedCurrency.lastFetchDate,
           let cachedCurrencies = cachedCurrency.loadCurrencies(),
           Date().timeIntervalSince(lastFetchDate) < refreshTimeInterval {
            return (cachedCurrencies, lastFetchDate)
        }
        let response = await apiManager.fetchCurrencyData()
        
        switch response {
        case .success(let currencies):
             var currencyMap = currencies.map {
                CurrencyModel(code: $0.code, name: $0.name, price: $0.rate)
            }
            currencyMap.append(CurrencyModel(code: "UAH", name: "Українська гривня", price: 1))
            
            let now = Date()
            cachedCurrency.saveCurrencies(currencyMap, date: now)
            return (currencyMap, now)
            
        case .failure(let error):
            print(error)
            
            if let cachedCurrencies = cachedCurrency.loadCurrencies(), let lastFetchDate = cachedCurrency.lastFetchDate {
                return (cachedCurrencies, lastFetchDate)
            }
            return nil
        }
        
    }
}
