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
public final class Gormsson: NSObject {
    private var manager: CBCentralManager?

    // Auto scan logic if needed
    private var needScan = false
    private var scanServices: [GattService]?
    private var scanOptions: [String: Any]?

    // Discovering services and characteristics
    /// The current peripheral is discovering his services and characteristics.
    internal var isDiscovering = false
    /// Number of services that are currently discovering.
    internal var discoveringService = 0
    /// The pending requests that wait to be resolved.
    internal var pendingRequests = [GattRequest]()
    /// The current active requests (notify requests).
    internal var currentRequests = [GattRequest]()

    /// The block to call each time a peripheral is found.
    internal var didDiscoverBlock: ((CBPeripheral, GattAdvertisement) -> Void)?

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
            scanServices = services
            scanOptions = options
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
        discoveringService = 0
        manager?.connect(peripheral)
        peripheral.delegate = self
        current = peripheral
    }

    /// Cancels an active or pending local connection to the current peripheral.
    public func disconnect() {
        if let peripheral = current {
            manager?.cancelPeripheralConnection(peripheral)
            cleanPeripheral()
            current = nil
        }
    }

    // MARK: - Internal functions

    /// Send a new scan if the first one was too early.
    internal func rescan() {
        if needScan, let block = didDiscoverBlock {
            scan(scanServices, options: scanOptions, didDiscover: block)
            needScan = false
            scanServices = nil
            scanOptions = nil
        }
    }

    /// Gets the CBCharacteristic of the current peripheral or nil if not in.
    internal func get(_ characteristic: CharacteristicProtocol) -> CBCharacteristic? {
        return current?.services?.first(where: { $0.uuid == characteristic.service.uuid })?
            .characteristics?.first(where: { $0.uuid == characteristic.uuid })
    }

    /// Reads the value of a characteristic from a request.
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

    /// Starts notifications for the value of a characteristic from a request.
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

    /// Writes the value of a characteristic from a request.
    internal func write(_ request: GattRequest,
                        value: DataConvertible,
                        type: CBCharacteristicWriteType = .withResponse) {
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

        current.writeValue(value.toData(),
                           for: cbCharacteristic,
                           type: type)
        currentRequests.append(request)
    }

    // MARK: - Private functions

    private func cleanPeripheral() {
        currentRequests.removeAll()
        pendingRequests.removeAll()
    }
}
