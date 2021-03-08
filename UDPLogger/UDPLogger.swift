//
//  UDPLogger.swift
//  UDPLogger
//
//  Created by kaho on 08/03/2021.
//

import Foundation
import Network

class UDPLogger {
    let connection: NWConnection
    init?(addr: String, port: UInt16) {
        guard let addr = IPv4Address(addr),
              let port = NWEndpoint.Port(rawValue: port) else {
            return nil
        }
        connection = .init(host: .ipv4(addr), port: port, using: .udp)
        connection.stateUpdateHandler = { newState in
            switch (newState) {
            case .ready:
                print("State: Ready")
            case .setup:
                print("State: Setup")
            case .cancelled:
                print("State: Cancelled")
            case .preparing:
                print("State: Preparing")
            default:
                print("ERROR! State not defined!\n")
            }
        }
        connection.start(queue: .global())
    }
    
    deinit {
        connection.cancel()
    }
    
    let resultHandler = NWConnection.SendCompletion.contentProcessed { NWError in
        guard NWError == nil else {
            print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            return
        }
    }
    
    func log(_ string: String) {
        connection.send(content: string.data(using: .utf8), completion: resultHandler)
    }

}
