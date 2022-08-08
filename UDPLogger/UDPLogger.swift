//
//  UDPLogger.swift
//  UDPLogger
//
//  Created by kaho on 08/03/2021.
//

import Foundation
import Network

class UDPLogger {
    var connection: NWConnection!
    init?(addr: String, port: UInt16) {
        guard let addr = IPv4Address(addr),
              let port = NWEndpoint.Port(rawValue: port) else {
            return nil
        }
        self.addr = addr
        self.port = port
        establishConnection()
    }
    let addr: IPv4Address
    let port: NWEndpoint.Port
    func establishConnection() {
        queue.async { [weak self] in
            print("[UDPLogger] Establishing new connection")
            guard let self = self else { return }
            self.connection = .init(host: .ipv4(self.addr), port: self.port, using: .udp)
            self.connection.stateUpdateHandler = { [weak self] newState in
                guard let self = self else { return }
                switch newState {
                case .ready:
                    print("[UDPLogger] Connection State: Ready")
                    self.sendPendingLogs()
                case .setup:
                    print("[UDPLogger] Connection State: Setup")
                case .cancelled:
                    print("[UDPLogger] Connection State: Cancelled")
                case .preparing:
                    print("[UDPLogger] Connection State: Preparing")
                case .failed(let error):
                    print("[UDPLogger] Connection State: Failed with error: \(error.localizedDescription)")
                    self.establishConnection()
                case .waiting(let error):
                    print("[UDPLogger] Connection State: Waiting with error: \(error.localizedDescription)")
                @unknown default:
                    print("[UDPLogger] Connection State: unknown")
                }
            }
            self.connection.start(queue: .global())
        }
    }

    let queue = DispatchQueue(label: "UDPLogger")
    var pendingLogs = [String]()
    deinit {
        connection.cancel()
    }

    let resultHandler = NWConnection.SendCompletion.contentProcessed { NWError in
        guard NWError == nil else {
            print("[UDPLogger] failed to send log with error: \(NWError!)")
            return
        }
    }

    func log(_ string: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if self.connection.state == .ready {
                self.connection.send(content: string.data(using: .utf8), completion: self.resultHandler)
            } else {
                self.pendingLogs.append(string)
            }
        }
    }

    func sendPendingLogs() {
        queue.async { [weak self] in
            guard let self = self, !self.pendingLogs.isEmpty else { return }
            print("[UDPLogger] sending pending logs")
            for log in self.pendingLogs {
                self.connection.send(content: log.data(using: .utf8), completion: self.resultHandler)
            }
            self.pendingLogs.removeAll()
        }
    }
}
