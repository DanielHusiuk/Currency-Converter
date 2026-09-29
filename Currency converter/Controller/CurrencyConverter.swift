//
//  CurrencyConverter.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 28.09.2026.
//

import Foundation

struct CurrencyConverter {
    let multiplier: Double
    
    func convertCurrency(amount: Double, from source: CurrencyModel, to target: CurrencyModel) -> Double {
        amount * (source.price / target.price) * multiplier
    }
}
