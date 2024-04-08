//
//  NetworkConnectivityMonitor.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 4/6/24.
//

import Foundation
import Network

final class NetworkConnectivityMonitor {
	
	private let networkMonitorQueue = DispatchQueue(label: "com.TinyBeansDemo.NetworkMonitor")
	private let monitor = NWPathMonitor()
	
	
	// MARK: - Initializer
	init() {
		activateNetworkPathMonitor()
	}
	
	
	private func activateNetworkPathMonitor() {
		
		monitor.pathUpdateHandler = { path in
			
			DispatchQueue.main.async {
				if path.status == .unsatisfied {
					// no internet
					let notification = Notification(name: NSNotification.Name(Constants.kNotificationNoInternet))
					NotificationCenter.default.post(notification)
				} else {
					// internet connected
					let notification = Notification(name: NSNotification.Name(Constants.kNotificationInternetConnected))
					NotificationCenter.default.post(notification)
				}
			}
		}
		
		monitor.start(queue: networkMonitorQueue)
	}
}
