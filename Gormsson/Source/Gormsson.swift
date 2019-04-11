//
//  Gormsson.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 04/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth

@objc
/// The manager’s state.
public enum GormssonState: Int {
    /// Uninitialized, wait for a valid state.
    case unknown
    /// BLE is powered on.
    case isPoweredOn
    /// You need to turn on BLE.
    case needBluetooth
    /// BLE was lost or disconnected.
    case didLostBluetooth
}

/// Gormsson is a BLE manager with blocks and auto cast type.
public final class Gormsson: NSObject {
    private var manager: CBCentralManager?
    private var isPoweredOn = false

    // Auto scan if needed
    private var needScan = false
    private var services: [GattService]?
    private var options: [String: Any]?

    // Block for => didDiscover peripheral:
    private var didDiscoverBlock: ((CBPeripheral, GattAdvertisement) -> Void)?

    // Current requests
    private var currentRequests = [GattRequest]()

    /// The current connected peripheral.
    public var current: CBPeripheral?

    /// The current state of the manager.
    @objc public dynamic var state: GormssonState = .unknown

    /// Init a new Gormsson manager
    ///
    /// - parameter queue:     The dispatch queue on which the events will be dispatched.
    ///                        If nil, the main queue will be used.
    /// - parameter options:   An optional dictionary specifying options for the manager
    public init(queue: DispatchQueue? = nil, options: [String: Any]? = nil) {
        super.init()
        manager = CBCentralManager(delegate: self, queue: queue, options: options)
    }

    /// Scans for peripherals that are advertising services.
    ///
    /// - parameter services:       An array of services that the app is interested in. In this case,
    ///                             each service represents the UUID of a service that a peripheral is advertising.
    /// - parameter options:        An optional dictionary specifying options to customize the scan.
    ///                             For available options, see Peripheral Scanning Options.
    /// - parameter didDiscover:    A block invoked when the manager discovers a peripheral while scanning.
    public func scan(_ services: [GattService]? = nil,
                     options: [String: Any]? = nil,
                     didDiscover: @escaping (CBPeripheral, GattAdvertisement) -> Void) {
        didDiscoverBlock = didDiscover
        guard isPoweredOn else {
            needScan = true
            self.services = services
            self.options = options
            return
        }

        manager?.scanForPeripherals(withServices: services?.map({ $0.uuid }), options: options)
    }

    /// Asks the central manager to stop scanning for peripherals.
    public func stopScan() {
        manager?.stopScan()
    }

    /// Establishes a local connection to a peripheral.
    ///
    /// - parameter peripheral:     The peripheral to which the central is attempting to connect.
    public func connect(_ peripheral: CBPeripheral) {
        if manager?.isScanning ?? false {
            stopScan()
        }
        manager?.connect(peripheral)
        current = peripheral //TODO: Shouldn't better to set in delegate function?
        current?.delegate = self
    }

    /// Cancels an active or pending local connection to the current peripheral.
    public func disconnect() {
        if let peripheral = current {
            manager?.cancelPeripheralConnection(peripheral)
        }
    }

    // MARK: - GattCharacteristic read / notify / write

    /// Reads the value of a characteristic.
    public func read<T>(_ characteristic: GattCharacteristic, success: @escaping (T?) -> Void) {
        read(characteristic.characteristic, success: success)
    }

    /// Starts notifications or indications for the value of a specified characteristic.
    public func notify<T>(_ characteristic: GattCharacteristic, success: @escaping (T?) -> Void) {
        notify(characteristic.characteristic, success: success)
    }

    /// Stops notifications or indications for the value of a specified characteristic.
    public func stopNotify(_ characteristic: GattCharacteristic) {
        stopNotify(characteristic.characteristic)
    }

    /// Writes the value of a characteristic.
    public func write<T>(_ characteristic: GattCharacteristic, value: T, success: @escaping (T?) -> Void) {
        write(characteristic.characteristic, value: value, success: success)
    }

    // MARK: - Generics and Custom read / notify / write

    /// Reads the value of a characteristic.
    public func read<T>(_ characteristic: CharacteristicProtocol, success: @escaping (T?) -> Void) {
        guard isPoweredOn, let current = current else { return }

        current.discoverServices([characteristic.service.uuid])
        currentRequests.append(GattRequest(.read, characteristic: characteristic, block: success))
    }

    /// Starts notifications or indications for the value of a specified characteristic.
    public func notify<T>(_ characteristic: CharacteristicProtocol, success: @escaping (T?) -> Void) {
        guard isPoweredOn, let current = current else { return }

        if let notifyCharacteristic = current.services?.first(where: { $0.uuid == characteristic.service.uuid })?
            .characteristics?.first(where: { $0.uuid == characteristic.uuid }) {
            // If not nil, discard new notify block
            guard !notifyCharacteristic.isNotifying else { return }
        }

        current.discoverServices([characteristic.service.uuid])
        currentRequests.append(GattRequest(.notify, characteristic: characteristic, block: success))
    }

    /// Stops notifications or indications for the value of a specified characteristic.
    public func stopNotify(_ characteristic: CharacteristicProtocol) {
        guard isPoweredOn, let current = current else { return }

        guard let notifyCharacteristic = current.services?.first(where: { $0.uuid == characteristic.service.uuid })?
            .characteristics?.first(where: { $0.uuid == characteristic.uuid }),
        notifyCharacteristic.isNotifying else { return }

        current.setNotifyValue(false, for: notifyCharacteristic)
        currentRequests = currentRequests
            .filter({ !($0.property == .notify && $0.characteristic.uuid == notifyCharacteristic.uuid) })
    }

    /// Writes the value of a characteristic.
    public func write<T>(_ characteristic: CharacteristicProtocol, value: T, success: @escaping (T?) -> Void) {
        guard isPoweredOn, let current = current else { return }

        current.discoverServices([characteristic.service.uuid])
        currentRequests.append(GattRequest(.write, characteristic: characteristic, block: success, value: value))
    }
}

extension Gormsson: CBCentralManagerDelegate {
    /// Invoked when the central manager’s state is updated.
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isPoweredOn = true
            state = .isPoweredOn
            if needScan, let block = didDiscoverBlock {
                scan(services, options: options, didDiscover: block)
                needScan = false
                services = nil
                options = nil
            }
        default:
            if isPoweredOn {
                isPoweredOn = false
                current = nil
                state = .didLostBluetooth
            } else {
                state = .needBluetooth
            }
        }
    }

    /// Invoked when the central manager discovers a peripheral while scanning.
    public func centralManager(_ central: CBCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               advertisementData: [String: Any],
                               rssi RSSI: NSNumber) {
        didDiscoverBlock?(peripheral, GattAdvertisement(with: advertisementData, rssi: RSSI.intValue))
    }

    /// Invoked when an existing connection with a peripheral is torn down.
    public func centralManager(_ central: CBCentralManager,
                               didDisconnectPeripheral peripheral: CBPeripheral,
                               error: Error?) {
        current = nil
        //TODO: Add auto-reconnect
    }
}

extension Gormsson: CBPeripheralDelegate {
    /// Invoked when you discover the peripheral’s available services.
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            currentRequests.filter({ $0.characteristic.service == service }).forEach { request in
                request.isPending = false
                peripheral.discoverCharacteristics([request.characteristic.uuid], for: service)
            }
        }
    }

    /// Invoked when you discover the characteristics of a specified service.
    public func peripheral(_ peripheral: CBPeripheral,
                           didDiscoverCharacteristicsFor service: CBService,
                           error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            var deletedRequest = [GattRequest]()

            currentRequests.filter({ $0.characteristic.uuid == characteristic.uuid })
                .filter({ characteristic.properties.contains($0.property) })
                .forEach { request in
                    switch request.property {
                    case .read:
                        read(characteristic, for: request)
                        deletedRequest.append(request)
                    case .notify:
                        if characteristic.isNotifying {
                            read(characteristic, for: request)
                        } else {
                            current?.setNotifyValue(true, for: characteristic)
                            //TODO: Should add auto-read on first notify
                        }
                    case .write:
                        if let value = request.value {
                            current?.writeValue(convert(value, from: request.characteristic.format),
                                                for: characteristic,
                                                type: .withResponse)
                        }
                        deletedRequest.append(request)
                    default:
                        print("Missing CBCharacteristicProperties:", request.property)
                    }
                }

            currentRequests = currentRequests.filter({ !deletedRequest.contains($0) })
        }
    }

    private func convert(_ value: Any, from type: Any.Type) -> Data {
        switch type {
        case is UInt8.Type:
            guard let value = value as? UInt8 else {
                return Data()
            }

            return Data(repeating: value, count: 1)
        default:
            return Data()
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func read(_ characteristic: CBCharacteristic, for request: GattRequest) {
        guard let data = characteristic.value else { return }

        switch request.characteristic.format {
        case is Int8.Type:
            if let block = request.block as? (Int8?) -> Void {
                var intValue = Int8(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += Int8(element) << (8 * index)
                }
                block(intValue)
            }
        case is UInt8.Type:
            if let block = request.block as? (UInt8?) -> Void {
                var intValue = UInt8(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += UInt8(element) << (8 * index)
                }
                block(intValue)
            }
        case is UInt16.Type:
            if let block = request.block as? (UInt16?) -> Void {
                var intValue = UInt16(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += UInt16(element) << (8 * index)
                }
                block(intValue)
            }
        case is UInt.Type:
            if let block = request.block as? (UInt?) -> Void {
                var intValue = UInt(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += UInt(element) << (8 * index)
                }
                block(intValue)
            }
        case is UInt64.Type:
            if let block = request.block as? (UInt64?) -> Void {
                var intValue = UInt64(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += UInt64(element) << (8 * index)
                }
                block(intValue)
            }
        case is String.Type:
            if let block = request.block as? (String?) -> Void {
                block(String(bytes: [UInt8](data), encoding: .utf8))
            }
        case is HeartRateMeasurementType.Type:
            if let block = request.block as? (HeartRateMeasurementType?) -> Void {
                block(HeartRateMeasurementType(with: data))
            }
        default:
            print("UNKNOWN TYPE")
        }
    }
}
