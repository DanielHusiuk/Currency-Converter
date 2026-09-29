//
//  MockApiManager.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 28.09.2026.
//

import Foundation

final class MockApiManager: ApiManagerProtocol {
    
    var result: Result<[CurrencyResponse], Error> = .success([
        CurrencyResponse(r030: 826, name: "Фунт стерлінгів", rate: 60.000, code: "GBP", exchangeDate: "28.09.2026"),
        CurrencyResponse(r030: 978, name: "Євро", rate: 50.000, code: "EUR", exchangeDate: "28.09.2026")
    ])
    
    func fetchCurrencyData() async -> Result<[CurrencyResponse], Error> {
        return result
    }
}
