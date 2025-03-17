//
//  ConnectivityObserver.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 14/03/2025.
//

import Foundation
import Network

public class ConnectivityObserver {
    public static let shared = ConnectivityObserver()
    
    public enum NetworkStatus {
        case wifiConnected
        case mobileData
        case noConnection
    }
    
    public var onNetworkStatusChange: ((NetworkStatus) -> Void)?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else {
                self?.onNetworkStatusChange?(.noConnection)
                return
            }
            
            self?.checkRealInternetAccess { hasInternet in
                guard let self = self else { return }
                
                if hasInternet {
                    if path.usesInterfaceType(.wifi) {
                        self.onNetworkStatusChange?(.wifiConnected)
                    } else if path.usesInterfaceType(.cellular) {
                        self.onNetworkStatusChange?(.mobileData)
                    } else {
                        self.onNetworkStatusChange?(.mobileData)
                    }
                } else {
                    self.onNetworkStatusChange?(.noConnection)
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func checkRealInternetAccess(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.apple.com/library/test/success.html") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
}
