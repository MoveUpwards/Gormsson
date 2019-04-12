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

    // Auto scan if needed
    internal var needScan = false
    internal var services: [GattService]?
    internal var options: [String: Any]?

    // Discovering services and characteristics
    internal var isDiscovering = false
    internal var discoveringService = 0
    internal var pendingRequests = [GattRequest]()

    // Block for => didDiscover peripheral:
    internal var didDiscoverBlock: ((CBPeripheral, GattAdvertisement) -> Void)?

    // Current requests
    internal var currentRequests = [GattRequest]()

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

    /// Clean up
    deinit {
        disconnect()
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
        guard state == .isPoweredOn else {
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
        isDiscovering = true
        manager?.connect(peripheral)
        peripheral.delegate = self
    }

    /// Cancels an active or pending local connection to the current peripheral.
    public func disconnect() {
        if let peripheral = current {
            manager?.cancelPeripheralConnection(peripheral)
            cleanPeripheral()
            current = nil
        }
    }

    // MARK: - GattCharacteristic read / notify / write

    /// Reads the value of a characteristic.
    public func read<T>(_ characteristic: GattCharacteristic,
                        success: @escaping (T?) -> Void,
                        error: @escaping (Error?) -> Void) {
        read(characteristic.characteristic, success: success, error: error)
    }

    /// Starts notifications or indications for the value of a specified characteristic.
    public func notify<T>(_ characteristic: GattCharacteristic,
                          success: @escaping (T?) -> Void,
                          error: @escaping (Error?) -> Void) {
        notify(characteristic.characteristic, success: success, error: error)
    }

    /// Stops notifications or indications for the value of a specified characteristic.
    public func stopNotify(_ characteristic: GattCharacteristic) {
        stopNotify(characteristic.characteristic)
    }

    /// Writes the value of a characteristic.
    public func write<T>(_ characteristic: GattCharacteristic,
                         value: T,
                         success: @escaping () -> Void,
                         error: @escaping (Error?) -> Void) {
        write(characteristic.characteristic, value: value, success: success, error: error)
    }

    // MARK: - Internal functions

    internal func read(_ request: GattRequest, append: Bool = true) {
       guard state == .isPoweredOn else {
            request.error?(GormssonError.powerOff)
            return
        }

        guard let current = current else {
            request.error?(GormssonError.deviceUnconnected)
            return
        }

        guard let cbCharacteristic = get(request.characteristic) else {
            request.error?(GormssonError.characteristicNotFound)
            return
        }

        current.readValue(for: cbCharacteristic)

        if append {
            currentRequests.append(request)
        }
    }

    internal func notify(_ request: GattRequest) {
        guard state == .isPoweredOn else {
            request.error?(GormssonError.powerOff)
            return
        }

        guard let current = current else {
            request.error?(GormssonError.deviceUnconnected)
            return
        }

        guard let cbCharacteristic = get(request.characteristic) else {
            request.error?(GormssonError.characteristicNotFound)
            return
        }

        guard !cbCharacteristic.isNotifying, !currentRequests.contains(request) else {
            request.error?(GormssonError.alreadyNotifying)
            return
        }

        current.setNotifyValue(true, for: cbCharacteristic)
        currentRequests.append(request)
    }

    internal func write(_ request: GattRequest) {
        guard state == .isPoweredOn else {
            request.error?(GormssonError.powerOff)
            return
        }

        guard let current = current else {
            request.error?(GormssonError.deviceUnconnected)
            return
        }

        guard let cbCharacteristic = get(request.characteristic) else {
            request.error?(GormssonError.characteristicNotFound)
            return
        }

        guard let value = request.value else {
            request.error?(GormssonError.missingValue)
            return
        }

        current.writeValue(convert(value, from: request.characteristic.format),
                           for: cbCharacteristic,
                           type: .withResponse)
        currentRequests.append(request)
    }

    // MARK: - Private functions

    private func get(_ characteristic: CharacteristicProtocol) -> CBCharacteristic? {
        return current?.services?.first(where: { $0.uuid == characteristic.service.uuid })?
            .characteristics?.first(where: { $0.uuid == characteristic.uuid })
    }

    private func cleanPeripheral() {
        currentRequests.removeAll()
        pendingRequests.removeAll()
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

    // MARK: - Generics and Custom read / notify / write

    /// Reads the value of a characteristic.
    public func read<T>(_ characteristic: CharacteristicProtocol,
                        success: @escaping (T?) -> Void,
                        error: @escaping (Error?) -> Void) {
        guard state == .isPoweredOn else {
            error(GormssonError.powerOff)
            return
        }

        let request = GattRequest(.read, characteristic: characteristic, success: success, error: error)

        guard !isDiscovering else {
            pendingRequests.append(request)
            return
        }

        read(request)
    }

    /// Starts notifications or indications for the value of a specified characteristic.
    public func notify<T>(_ characteristic: CharacteristicProtocol,
                          success: @escaping (T?) -> Void,
                          error: @escaping (Error?) -> Void) {
        guard state == .isPoweredOn else {
            error(GormssonError.powerOff)
            return
        }

        let request = GattRequest(.notify, characteristic: characteristic, success: success, error: error)

        guard !isDiscovering else {
            guard !pendingRequests.contains(request) else {
                request.error?(GormssonError.alreadyNotifying)
                return
            }

            pendingRequests.append(request)
            return
        }

        notify(request)
    }

    /// Stops notifications or indications for the value of a specified characteristic.
    public func stopNotify(_ characteristic: CharacteristicProtocol) {
        currentRequests = currentRequests
            .filter({ !($0.property == .notify && $0.characteristic.uuid == characteristic.uuid) })
        pendingRequests = pendingRequests
            .filter({ !($0.property == .notify && $0.characteristic.uuid == characteristic.uuid) })

        guard let cbCharacteristic = get(characteristic), cbCharacteristic.isNotifying else { return }

        current?.setNotifyValue(false, for: cbCharacteristic)
    }

    /// Writes the value of a characteristic.
    public func write<T>(_ characteristic: CharacteristicProtocol,
                         value: T,
                         success: @escaping () -> Void,
                         error: @escaping (Error?) -> Void) {
        guard state == .isPoweredOn else {
            error(GormssonError.powerOff)
            return
        }

        let request = GattRequest(.write,
                                  characteristic: characteristic,
                                  success: success,
                                  error: error,
                                  value: value)

        guard !isDiscovering else {
            pendingRequests.append(request)
            return
        }

        write(request)
    }
}
