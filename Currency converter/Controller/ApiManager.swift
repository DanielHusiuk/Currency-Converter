//
//  ApiManager.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 22.09.2026.
//

import Foundation

enum DataError: Error {
    case invalidData
    case invalidResponse
    case message(Error)
}

protocol ApiManagerProtocol: AnyObject {
    func fetchCurrencyData() async -> Result<[CurrencyResponse], Error>
}

final class ApiManager: ApiManagerProtocol {
    
    func fetchCurrencyData() async -> Result<[CurrencyResponse], Error> {
        let urlString = Bundle.main.object(forInfoDictionaryKey: "EXCHANGE_URL") as? String ?? ""
        guard let url = URL(string: urlString) else {
            return .failure(DataError.invalidData)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                return .failure(DataError.invalidResponse)
            }
            
            let rates = try JSONDecoder().decode([CurrencyResponse].self, from: data)
            return .success(rates)
            
        } catch {
            return .failure(DataError.message(error))
        }
    }
}
