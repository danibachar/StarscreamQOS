//
//  Config.swift
//  StarscreamQOS
//
//  Created by Daniel Bachar on 08/05/2021.
//  Copyright © 2021 Daniel Bachar. All rights reserved.
//
import Foundation

public struct Config {
    public let timeout: TimeInterval
    public let data: Data
    public let fireInterval: TimeInterval
    public let autoConnect: Bool
    public let maxReconnectRetry: Int
    public init(timeout: TimeInterval,
                 data: Data,
                 fireInterval: TimeInterval,
                 autoConnect: Bool,
                 maxReconnectRetry: Int) {
        // The interval where we release ping <-> pong requests must be bigger than the timeout
        self.fireInterval = (fireInterval - timeout) > 2.0 ? fireInterval : fireInterval + 2
        self.timeout = timeout
        self.data = data
        self.autoConnect = autoConnect
        self.maxReconnectRetry = maxReconnectRetry
    }
    public static let defaultConfig: Config = Config(timeout: 5.0,
                                              // As this package was tested mainly against ws npm package, which limits ping -> pong packets to 125 bytes this is the default configuration
                                                     data: Data(repeating: 1, count: 124),
                                                     fireInterval: 7.0,
                                                     autoConnect: false,
                                                     maxReconnectRetry: 3)
}
