//
//  StarscreamQOS.swift
//  StarscreamQOS
//
//  Created by Daniel Bachar on 08/05/2021.
//  Copyright © 2021 Daniel Bachar. All rights reserved.
//

import Foundation
import UIKit
import Starscream

public protocol StarscreamQOSType {
    
    /// Events proxy - set the way you want to be notified on socket evevnts
    var socketDelegate: WebSocketDelegate? { get set }
    var onSocketEvent: ((WebSocketEvent) -> Void)? { get set }
    
    /// Get notify on connection quality changes
    var connectionQualityListener: ((QOS) -> Void)? { get set }
    
    /// wrting to the underlying socket
    /// - Parameter string: desire string to write
    func write(string: String)
    
    /// Connect action of the underlying socker
    func connect()
    
    /// Disconnect action of the underlying socket
    func disconnect()
}

final public class StarscreamQOS: StarscreamQOSType {
    /// State
    private var pingPongTimer: Timer?
    private var counterTimer: Timer?
    private var counter: TimeInterval = 0
    private var isConnected: Bool = false
    /// Injections
    private let socket: WebSocket
    private let config: Config
    private let notificationCenter: NotificationCenter
    public init(socket: WebSocket,
                onSocketEvent: ((WebSocketEvent) -> Void)? = nil,
                connectionQualityListener: ((QOS) -> Void)? = nil,
                socketDelegate: WebSocketDelegate? = nil,
                config: Config = Config.defaultConfig,
                notificationCenter: NotificationCenter = .default) {
        self.socket = socket
        self.onSocketEvent = onSocketEvent
        self.socketDelegate = socketDelegate
        self.connectionQualityListener = connectionQualityListener
        self.config = config
        self.notificationCenter = notificationCenter
        
        self.socket.delegate = self
        if config.autoConnect {
            self.socket.connect()
        }
    }
    
    deinit {
        invalidateTimers()
        unregisterNotfications()
    }
    
    /// StarscreamWrapperType
    weak public var socketDelegate: WebSocketDelegate?
    
    public var onSocketEvent: ((WebSocketEvent) -> Void)? {
        didSet {
            socket.onEvent = { [weak self]  event in
                self?.handle(event)
                self?.onSocketEvent?(event) // Pass down the line
            }
        }
    }
    
    public var connectionQualityListener: ((QOS) -> Void)? {
        didSet { startConnectionQualityListener() }
    }
    
    public func write(string: String) {
        socket.write(string: string)
    }
    
    public func connect() {
        socket.connect()
    }
    
    public func disconnect() {
        socket.disconnect()
    }
}

// MARK: - Ping Pong handlers
private extension StarscreamQOS {
    func startConnectionQualityListener() {
        // TODO - add bg handling!!!
        pingPongTimer?.invalidate()
        pingPongTimer = Timer.scheduledTimer(timeInterval: config.fireInterval,
                                             target: self,
                                             selector: #selector(sendPing),
                                             userInfo: nil,
                                             repeats: true)
        sendPing()
    }
    
    func handle(_ event: WebSocketEvent) {
        switch event {
        case .connected:
            isConnected = true
        case .disconnected, .cancelled:
            isConnected = false
        case .pong:
            handlePongEvent()
        case .error(let error):
            // TODO - add error hanlding
            print("error \(error.debugDescription)")
            isConnected = false
            guard let error = error as? WSError else { return }
            switch error.type {
            case .serverError:
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    func handlePongEvent() {
        guard isConnected else { return }
        // Update on QOS
        let connectionQuality = quality(by: self.config.timeout, and: self.counter)
        self.connectionQualityListener?(connectionQuality)
        // Reser Steper
        resetStepsCounter()
    }
    
    private func resetStepsCounter() {
        counter = 0
        
        counterTimer?.invalidate()
        counterTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                            target: self,
                                            selector: #selector(incStepsCounter),
                                            userInfo: nil,
                                            repeats: true)
    }
    
    @objc private func incStepsCounter() { counter += 0.5 }
    
    @objc private func sendPing() {
        socket.write(ping: config.data)
    }
}

// MARK: - Reconnection Retry
private extension StarscreamQOS {
    
}

// MARK: - Notification handling
private extension StarscreamQOS {
    func registerNotifications() {
        notificationCenter.addObserver(self,
                                       selector: #selector(willResignActive),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(didBecomeActive),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)
    }
    
    func unregisterNotfications() {
        notificationCenter.removeObserver(self)
    }
    
    @objc func willResignActive() {
        invalidateTimers()
        unregisterNotfications()
    }
    
    @objc func didBecomeActive() {
        registerNotifications()
        startConnectionQualityListener()
    }
    
    func invalidateTimers() {
        pingPongTimer?.invalidate()
        pingPongTimer = nil
        counterTimer?.invalidate()
        counterTimer = nil
        socket.disconnect()
    }
}

// MARK: - WebSocketDelegate
extension StarscreamQOS: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        self.handle(event)
        self.socketDelegate?.didReceive(event: event, client: client)
    }
}


// MARK: - Quality calculator
private func quality(by interval: TimeInterval, and steps: TimeInterval) -> QOS {
    /* logic as follow:
     1) 85% - 100% of timeout counts as `nonOperational`
     2) 50& - 85% of timeout counts as `bad`
     3) 35% - 50% of timeout counts as ok
     4) 20% - 35% of timeout counts as `good`
     5) 0% - 20% of timeout counts as `superb`
     */
    
    switch steps/interval {
    case 0...0.2:
        return .superb
    case 0.2...0.35:
        return .good
    case 0.35...0.5:
        return .ok
    case 0.5...0.85:
        return .bad
    default:
        return .nonOperational
    }
}