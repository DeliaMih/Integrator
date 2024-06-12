//
//  IntegratorClient.swift
//
//
//  Created by Baluta Eugen on 13.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import IntegratorDefaults

public class IntegratorClient {
    public static var shared = IntegratorClient()
    var session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: Analitycs
    public func postPurchase(
        transactionId: String?,
        trackingIdentifier: String?
    ) {
        guard let url = URL(string: "https://analytics.nomadroot.com/callback/status") else { return }
        let sessionDateComponents = Calendar.current.dateComponents(
            [.second],
            from: IntegratorDefaults.integrationSessionStart,
            to: Date()
        )
        let sessionDuration = sessionDateComponents.second ?? 0
        
        post(
            url: url,
            parameters: [
                "TransactionID": transactionId ?? "Unknown",
                "LastSessionDuration": sessionDuration,
                "DeepLink": trackingIdentifier ?? "Unknown"
            ] as [String : Any]
        ) { }
    }
}

extension IntegratorClient {
    public func get(url: URL, completion: @escaping () -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { _, _, _ in
            completion()
        }
        .resume()
    }
    
    public func get<T: Codable>(url: URL, _ type: T.Type, completion: @escaping (T?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { [weak self] data, _, error in
            completion(self?.decode(data: data, type))
        }
        .resume()
    }
    
    public func post(url: URL, parameters: [String: Any], completion: @escaping () -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = parameters.data
        
        session.dataTask(with: request) { _, _, _ in
            completion()
        }
        .resume()
    }
    
    public func post<T: Codable>(
        url: URL,
        parameters: [String: Any],
        _ type: T.Type,
        completion: @escaping (T?) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.httpBody = parameters.data
        
        session.dataTask(with: request) { [weak self] data, _, error in
            completion(self?.decode(data: data, type))
        }
        .resume()
    }
    
    private func decode<T: Codable>(data: Data?, _ type: T.Type) -> T? {
        guard let data else { return nil }
        do {
            let decoded = try JSONDecoder().decode(type, from: data)
            return decoded
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
}

fileprivate extension Dictionary {
    var data: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
