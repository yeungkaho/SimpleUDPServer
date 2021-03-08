//
//  LogServer.swift
//  LogServer
//
//  Created by kaho on 08/03/2021.
//

import Foundation
import Network

final class LogServer {
    private let listener: NWListener
    
    private var clients = [LogSession]()
    
    init(port: UInt16 = 1089) {
        listener = try! NWListener(using: .udp, on: NWEndpoint.Port(rawValue: port)!)
        listener.stateUpdateHandler = stateDidChange(to:)
        listener.newConnectionHandler = didAccept(for:)
    }
    
    func start() {
        listener.start(queue: .main)
    }
    
    private func stateDidChange(to newState: NWListener.State) {
        print("NWListener stateDidChange: \(newState)")
    }
    
    private func didAccept(for connection: NWConnection) {
        print("NWListener didAccept: \(connection)")
        clients.append(.init(connection: connection))
    }
}

