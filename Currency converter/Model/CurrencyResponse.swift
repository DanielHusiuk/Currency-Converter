//
//  CurrencyResponse.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 22.09.2026.
//

struct CurrencyResponse: Codable {
    let r030: Int
    let name: String
    let rate: Double
    let code: String
    let exchangeDate: String
    
    enum CodingKeys: String, CodingKey {
        case r030
        case name = "txt"
        case rate
        case code = "cc"
        case exchangeDate = "exchangedate"
    }
}
