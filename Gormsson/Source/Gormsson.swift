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
    public func deviceName(_ peripheral: CBPeripheral) -> String? {
        return peripheral.name // Do we keep this?
    }

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
}
