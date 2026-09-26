//
//  CurrencyCache.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 25.09.2026.
//

import Foundation

struct CurrencyCache {
    private let currenciesKey = "cachedCurrencies"
    private let dateKey = "lastFetchDate"
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    var lastFetchDate: Date? {
        defaults.object(forKey: dateKey) as? Date
    }
    
    func loadCurrencies() -> [CurrencyModel]? {
        guard let data = defaults.data(forKey: currenciesKey) else { return nil }
        return try? JSONDecoder().decode([CurrencyModel].self, from: data)
    }
    
    func saveCurrencies(_ currencies: [CurrencyModel], date: Date) {
        guard let data = try? JSONEncoder().encode(currencies) else { return }
        defaults.set(data, forKey: currenciesKey)
        defaults.set(date, forKey: dateKey)
    }
}
