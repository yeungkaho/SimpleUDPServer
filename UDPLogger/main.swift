//
//  main.swift
//  UDPLogger
//
//  Created by kaho on 08/03/2021.
//

import Foundation

print("enter test logs:")

let logger = UDPLogger(addr: "127.0.0.1", port: 1089)!

while let log = readLine() {
    logger.log(log)
}


