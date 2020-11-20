//
//  Gormsson.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 04/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

/// Gormsson is a BLE manager with blocks and auto cast type.
@available(iOS 9.0, *)
open class Gormsson {
    private let manager: CentralManager

    /// Init a new Gormsson manager
    ///
    /// - parameter queue:     The dispatch queue on which the events will be dispatched.
    ///                        If nil, the main queue will be used.
    /// - parameter options:   An optional dictionary specifying options for the manager
    public init(queue: DispatchQueue? = nil, options: [String: Any]? = nil) {
        manager = CentralManager(queue: queue, options: options)
    }

    // MARK: - Observe

    /// The block to observe manager's state.
    public func observe(options: [ValueObservingOptions]? = nil, _ stateBlock: @escaping (GormssonState) -> Void) {
        manager.observe(options: options, stateBlock)
    }

    // MARK: - Scan

    /// Scans for peripherals that are advertising services.
    ///
    /// - parameter services:       An array of services that the app is interested in. In this case,
    ///                             each service represents the UUID of a service that a peripheral is advertising.
    ///                             A valid UUID with a 16-bit, 32-bit, or 128-bit UUID string representation.
    ///                             The expected format for 128-bit UUIDs is a string punctuated by hyphens,
    ///                             for example 68753A44-4D6F-1226-9C60-0050E4C00067.
    /// - parameter options:        An optional dictionary specifying options to customize the scan.
    ///                             For available options, see Peripheral Scanning Options.
    /// - parameter didDiscover:    A block invoked when the manager discovers a peripheral while scanning.
    public func scan(_ services: [GattService]? = nil,
                     options: [String: Any]? = nil,
                     didDiscover: @escaping (Result<GormssonPeripheral, Error>) -> Void) {
        manager.scan(services, options: options, didDiscover: didDiscover)
    }

    /// Scans for peripherals that are advertising services.
    ///
    /// - parameter services:       An array of services that the app is interested in. In this case,
    ///                             each service represents the UUID of a service that a peripheral is advertising.
    ///                             A valid UUID with a 16-bit, 32-bit, or 128-bit UUID string representation.
    ///                             The expected format for 128-bit UUIDs is a string punctuated by hyphens,
    ///                             for example 68753A44-4D6F-1226-9C60-0050E4C00067.
    /// - parameter options:        An optional dictionary specifying options to customize the scan.
    ///                             For available options, see Peripheral Scanning Options.
    /// - parameter delay:          The duration in seconds between each refresh.
    /// - parameter timeout:        The timeout in seconds that remove a scanned device.
    /// - parameter didUpdate:      A block invoked every *delay* seconds with the list of
    ///                             peripheral (new, updated or deleted).
    public func scan(_ services: [GattService]? = nil,
                     options: [String: Any]? = nil,
                     delay: TimeInterval,
                     timeout: TimeInterval,
                     didUpdate: @escaping (Result<[GormssonPeripheral], Error>) -> Void) {
        manager.scan(services, options: options, delay: delay, timeout: timeout, didUpdate: didUpdate)
    }

    /// Asks the central manager to stop scanning for peripherals.
    public func stopScan() {
        manager.stopScan()
    }

    // MARK: - Connect

    /// Establishes a local connection to a peripheral.
    ///
    /// - parameter peripheral:     The peripheral to which the central is attempting to connect.
    public func connect(_ peripheral: CBPeripheral,
                        shouldStopScan: Bool = false,
                        success: (() -> Void)? = nil,
                        failure: ((Error?) -> Void)? = nil,
                        didReadyHandler: (() -> Void)? = nil,
                        didDisconnectHandler: ((Error?) -> Void)? = nil) {
        manager.connect(peripheral, shouldStopScan: shouldStopScan, success: success, failure: failure,
                        didReadyHandler: didReadyHandler, didDisconnectHandler: didDisconnectHandler)
    }

    /// Cancels an active or pending local connection to the peripheral.
    public func disconnect(_ peripheral: CBPeripheral) {
        manager.cancel(peripheral)
    }

    // MARK: - Read

    /// Reads the value of a base characteristic.
    public func read(_ characteristic: GattCharacteristic,
                     on peripheral: CBPeripheral,
                     result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.read(characteristic.characteristic, on: peripheral, result: result)
    }

    /// Reads the value of a custom characteristic.
    public func read(_ characteristic: CharacteristicProtocol,
                     on peripheral: CBPeripheral,
                     result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.read(characteristic, on: peripheral, result: result)
    }

    // MARK: - Notify

    /// Starts notifications or indications for the value of a base characteristic.
    public func notify(_ characteristic: GattCharacteristic,
                       on peripheral: CBPeripheral,
                       result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.notify(characteristic.characteristic, on: peripheral, result: result)
    }

    /// Starts notifications or indications for the value of a base characteristic.
    public func notify(_ characteristic: CharacteristicProtocol,
                       on peripheral: CBPeripheral,
                       result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.notify(characteristic, on: peripheral, result: result)
    }

    /// Stops notifications or indications for the value of a custom characteristic.
    public func stopNotify(_ characteristic: GattCharacteristic, on peripheral: CBPeripheral) {
        manager.stopNotify(characteristic.characteristic, on: peripheral)
    }

    /// Stops notifications or indications for the value of a custom characteristic.
    public func stopNotify(_ characteristic: CharacteristicProtocol, on peripheral: CBPeripheral) {
        manager.stopNotify(characteristic, on: peripheral)
    }

    // MARK: - Write

    /// Writes the value of a base characteristic.
    public func write(_ characteristic: GattCharacteristic,
                      on peripheral: CBPeripheral,
                      value: DataConvertible,
                      type: CBCharacteristicWriteType = .withResponse,
                      result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.write(characteristic.characteristic, on: peripheral, value: value, type: type, result: result)
    }

    /// Writes the value of a custom characteristic.
    public func write(_ characteristic: CharacteristicProtocol,
                      on peripheral: CBPeripheral,
                      value: DataConvertible,
                      type: CBCharacteristicWriteType = .withResponse,
                      result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.write(characteristic, on: peripheral, value: value, type: type, result: result)
    }

    // MARK: - Execute

    /// Start to connect each device, then **execute** the characteristic, return the result and disconnect.
    /// At the end of all requests (or if timeout is reach), call completion.
    public func execute(_ characteristic: GattCharacteristic,
                        on devices: [CBPeripheral],
                        result: @escaping (Result<(peripheral: CBPeripheral, data: DataInitializable), Error>) -> Void,
                        timeout: Int = 30,
                        completion: ((Error?) -> Void)? = nil) {
        execute(characteristic.characteristic, on: devices, result: result, timeout: timeout, completion: completion)
    }

    /// Start to connect each device, then **execute** the characteristic, return the result and disconnect.
    /// At the end of all requests (or if timeout is reach), call completion.
    public func execute(_ characteristic: CharacteristicProtocol,
                        on devices: [CBPeripheral],
                        result: @escaping (Result<(peripheral: CBPeripheral, data: DataInitializable), Error>) -> Void,
                        timeout: Int = 30,
                        completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let downloadGroup = DispatchGroup()

            devices.forEach { peripheral in
                downloadGroup.enter()

                var hasResult = false
                self?.manager.connect(peripheral, success: {
                    // Everything is fine, wait to be ready
                }, failure: { error in
                    if let error = error, !hasResult {
                        hasResult = true
                        result(.failure(error))
                    }
                }, didReadyHandler: {
                    self?.manager.read(characteristic, on: peripheral) { currentResult in
                        if case let .failure(error) = currentResult, !hasResult {
                            hasResult = true
                            result(.failure(error))
                        } else if case let .success(value) = currentResult, !hasResult {
                            hasResult = true
                            result(.success((peripheral, value)))
                        }
                        self?.disconnect(peripheral)
                    }
                }, didDisconnectHandler: { error in
                    if let error = error, !hasResult {
                        hasResult = true
                        result(.failure(error))
                    }

                    downloadGroup.leave()
                })
            }

            // Wait for the timeout, if needed
            let result = downloadGroup.wait(timeout: .now() + .seconds(timeout))

            DispatchQueue.main.async {
                guard result == .timedOut else {
                    completion?(nil) // Completed with success
                    return
                }

                completion?(GormssonError.timedOut)
            }
        }
    }
}
