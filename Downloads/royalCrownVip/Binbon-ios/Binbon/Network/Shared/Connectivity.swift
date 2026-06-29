//
//  Connectivity.swift
//  Binbon
//
//  Created by Salah Khaled on 28/02/2026.
//

import Foundation
import Network
import Combine

final class Connectivity {
    
    // MARK: - Properties
    static let shared = Connectivity()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ReachabilityMonitor")
    private var lastStatus: NWPath.Status = .requiresConnection
    private var isFirstUpdate = true
    
    // MARK: - Public
    var isOnline: Bool { lastStatus == .satisfied }
    
    // MARK: - Methods
    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            if self.isFirstUpdate {
                self.isFirstUpdate = false
                self.lastStatus = path.status
                return
            }
            
            guard path.status != self.lastStatus else { return }
            self.lastStatus = path.status
            
            DispatchQueue.main.async {
                self.handleStatusChange(path.status)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    // MARK: - Event
    private func handleStatusChange(_ status: NWPath.Status) {
        
        let type: ToastEntry = status == .satisfied ? .online : .offline
        let message = String(localized: status == .satisfied ? "You're back online!" : "You're offline!")
        
        Toaster.shared.show(type, message)
    }
}


// MARK: - Modifier
import SwiftUI

private struct ConnectivityModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear { Connectivity.shared.start() }
    }
}

extension View {
    func connectivity() -> some View {
        self.modifier(ConnectivityModifier())
    }
}
