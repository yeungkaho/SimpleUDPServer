//
//  LogClientSession.swift
//  LogServer
//
//  Created by kaho on 08/03/2021.
//

import Foundation
import Network

class LogSession {
    
    let connection: NWConnection
    let remoteAddr: String
    let remotePort: UInt16
    
    init(connection: NWConnection) {
        self.connection = connection
        switch connection.endpoint {
        case .hostPort(host: let host, port: let port):
            self.remoteAddr = host.debugDescription
            self.remotePort = port.rawValue
        case .url(let url):
            self.remoteAddr = url.host!
            self.remotePort = UInt16(url.port ?? -1)
        default:
            self.remoteAddr = "unknown"
            self.remotePort = 0
        }
        connection.start(queue: .global())
        startReading()
    }
    
    private func startReading() {
        connection.receiveMessage { [weak self] (data, ctx, complete, error) in
            if let self = self, let data = data, let str = String(data: data, encoding: .utf8) {
                print("[\(self.remoteAddr):\(self.remotePort)] " + str)
            }
            if let error = error {
                print(error)
            }
            self?.startReading()
        }
    }
    
    deinit {
        connection.cancel()
    }
}
