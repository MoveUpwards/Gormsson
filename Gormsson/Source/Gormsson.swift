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

    /// Device Name (0x2A00) as it is not accessible the normal way.
    public var deviceName: String? {
        return manager.current?.name
    }

    /// Init a new Gormsson manager
    ///
    /// - parameter queue:     The dispatch queue on which the events will be dispatched.
    ///                        If nil, the main queue will be used.
    /// - parameter options:   An optional dictionary specifying options for the manager
    public init(queue: DispatchQueue? = nil, options: [String: Any]? = nil) {
        manager = CentralManager(queue: queue, options: options)
    }

    /// Clean up
    deinit {
        disconnect()
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
    /// - parameter options:        An optional dictionary specifying options to customize the scan.
    ///                             For available options, see Peripheral Scanning Options.
    /// - parameter didDiscover:    A block invoked when the manager discovers a peripheral while scanning.
    public func scan(_ services: [GattService]? = nil,
                     options: [String: Any]? = nil,
                     didDiscoverHandler: @escaping (CBPeripheral, GattAdvertisement) -> Void) {
        manager.scan(services, options: options, didDiscoverHandler: didDiscoverHandler)
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
                        success: ((CBPeripheral) -> Void)? = nil,
                        failure: ((CBPeripheral, Error?) -> Void)? = nil,
                        didReadyHandler: (() -> Void)? = nil,
                        didDisconnectHandler: ((CBPeripheral, Error?) -> Void)? = nil) {
        manager.connect(peripheral, shouldStopScan: shouldStopScan, success: success, failure: failure,
                        didReadyHandler: didReadyHandler, didDisconnectHandler: didDisconnectHandler)
    }

    /// Cancels an active or pending local connection to the current peripheral.
    public func disconnect() {
        manager.disconnect()
    }

    // MARK: - Read

    /// Reads the value of a base characteristic.
    public func read(_ characteristic: GattCharacteristic,
                     result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.read(characteristic.characteristic, result: result)
    }

    /// Reads the value of a custom characteristic.
    public func read(_ characteristic: CharacteristicProtocol,
                     result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.read(characteristic, result: result)
    }

    // MARK: - Notify

    /// Starts notifications or indications for the value of a base characteristic.
    public func notify(_ characteristic: GattCharacteristic,
                       result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.notify(characteristic.characteristic, result: result)
    }

    /// Starts notifications or indications for the value of a base characteristic.
    public func notify(_ characteristic: CharacteristicProtocol,
                       result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.notify(characteristic, result: result)
    }

    /// Stops notifications or indications for the value of a custom characteristic.
    public func stopNotify(_ characteristic: GattCharacteristic) {
        manager.stopNotify(characteristic.characteristic)
    }

    /// Stops notifications or indications for the value of a custom characteristic.
    public func stopNotify(_ characteristic: CharacteristicProtocol) {
        manager.stopNotify(characteristic)
    }

    // MARK: - Write

    /// Writes the value of a base characteristic.
    public func write(_ characteristic: GattCharacteristic,
                      value: DataConvertible,
                      type: CBCharacteristicWriteType = .withResponse,
                      result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.write(characteristic.characteristic, value: value, type: type, result: result)
    }

    /// Writes the value of a custom characteristic.
    public func write(_ characteristic: CharacteristicProtocol,
                      value: DataConvertible,
                      type: CBCharacteristicWriteType = .withResponse,
                      result: @escaping (Result<DataInitializable, Error>) -> Void) {
        manager.write(characteristic, value: value, type: type, result: result)
    }
}
