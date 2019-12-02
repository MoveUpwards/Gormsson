//
//  CentralManager.swift
//  Gormsson
//
//  Created by Mac on 05/11/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

internal final class CentralManager: NSObject {
    private var cbManager: CBCentralManager?
    private var peripheralManager: PeripheralManager?

    // Auto scan logic if needed
    private var needScan = false
    private var scanServices: [GattService]?
    private var scanOptions: [String: Any]?

    /// The current state of the manager.
    private var state: GormssonState = .unknown {
        didSet {
            guard distinctState else {
                stateBlock?(state)
                return
            }

            if oldValue != state {
                stateBlock?(state)
            }
        }
    }
    /// The block to call each time the state change
    private var stateBlock: ((GormssonState) -> Void)?
    /// Only notify value change if distinct
    private var distinctState = false

    /// The current connected peripheral.
    internal var current: CBPeripheral?

    /// The block to call each time a peripheral is connected.
    internal var didConnect: ((CBPeripheral) -> Void)?
    /// The block to call when a peripheral fails to connect.
    internal var didFailConnect: ((CBPeripheral, Error?) -> Void)?
    /// The block to call once all custom services and characterics.
    internal var didReady: (() -> Void)?
    /// The block to call each time a peripheral is disconnect.
    internal var didDisconnect: ((CBPeripheral, Error?) -> Void)?
    /// The block to call each time a peripheral is found.
    internal var didDiscover: ((CBPeripheral, GattAdvertisement) -> Void)?

    // Discovering services and characteristics
    /// The current peripheral is discovering his services and characteristics.
    internal var isDiscovering = false
    /// Number of services that are currently discovering.
    internal var discoveringService = 0
    /// The pending requests that wait to be resolved.
    internal var pendingRequests = [GattRequest]()
    /// The current active requests (notify requests).
    internal var currentRequests = [GattRequest]()

    internal init(queue: DispatchQueue? = nil, options: [String: Any]? = nil) {
        super.init()
        cbManager = CBCentralManager(delegate: self, queue: queue, options: options)
        peripheralManager = PeripheralManager(self)
    }

    internal func observe(options: [ValueObservingOptions]? = nil, _ stateBlock: @escaping (GormssonState) -> Void) {
        self.stateBlock = stateBlock

        guard let options = options else { return }

        if options.contains(.initial) {
            stateBlock(state)
        }
        if options.contains(.distinct) {
            distinctState = true
        }
    }

    internal func updateState(with cbState: CBManagerState) {
        switch cbState {
        case .poweredOn:
            state = .isPoweredOn
            rescan()
        default:
            if state == .isPoweredOn {
                current = nil
                state = .didLostBluetooth
            } else {
                state = .needBluetooth
            }
        }
    }

    internal func scan(_ services: [GattService]? = nil,
                       options: [String: Any]? = nil,
                       didDiscoverHandler: @escaping (CBPeripheral, GattAdvertisement) -> Void) {
        didDiscover = didDiscoverHandler
        guard state == .isPoweredOn else {
            needScan = true
            scanServices = services
            scanOptions = options
            return
        }

        cbManager?.scanForPeripherals(withServices: services?.map({ $0.uuid }), options: options)
    }

    internal func stopScan() {
        cbManager?.stopScan()
    }

    internal func connect(_ peripheral: CBPeripheral,
                          shouldStopScan: Bool = false,
                          success: ((CBPeripheral) -> Void)? = nil,
                          failure: ((CBPeripheral, Error?) -> Void)? = nil,
                          didReadyHandler: (() -> Void)? = nil,
                          didDisconnectHandler: ((CBPeripheral, Error?) -> Void)? = nil) {
        if shouldStopScan, cbManager?.isScanning ?? false {
            stopScan()
        }
        didConnect = success
        didFailConnect = failure
        didReady = didReadyHandler
        didDisconnect = didDisconnectHandler
        isDiscovering = true
        discoveringService = 0
        cbManager?.connect(peripheral)
        peripheral.delegate = self.peripheralManager
        current = peripheral
    }

    /// Gets the CBCharacteristic of the current peripheral or nil if not in.
    internal func get(_ characteristic: CharacteristicProtocol) -> CBCharacteristic? {
        return current?.services?.first(where: { $0.uuid == characteristic.service.uuid })?
            .characteristics?.first(where: { $0.uuid == characteristic.uuid })
    }

    /// Reads the value of a custom characteristic.
    internal func read(_ characteristic: CharacteristicProtocol,
                       result: @escaping (Result<DataInitializable, Error>) -> Void) {
        guard state == .isPoweredOn else {
            result(.failure(GormssonError.powerOff))
            return
        }

        let request = GattRequest(.read, characteristic: characteristic, result: result)

        guard !isDiscovering else {
            pendingRequests.append(request)
            return
        }

        read(request)
    }

    /// Starts notifications or indications for the value of a base characteristic.
    internal func notify(_ characteristic: CharacteristicProtocol,
                         result: @escaping (Result<DataInitializable, Error>) -> Void) {
        guard state == .isPoweredOn else {
            result(.failure(GormssonError.powerOff))
            return
        }

        let request = GattRequest(.notify, characteristic: characteristic, result: result)

        guard !isDiscovering else {
            guard !pendingRequests.contains(request) else {
                request.result?(.failure(GormssonError.alreadyNotifying))
                return
            }

            pendingRequests.append(request)
            return
        }

        notify(request)
    }

    /// Stops notifications or indications for the value of a custom characteristic.
    internal func stopNotify(_ characteristic: CharacteristicProtocol) {
        guard let cbCharacteristic = get(characteristic), cbCharacteristic.isNotifying else { return }

        current?.setNotifyValue(false, for: cbCharacteristic)
    }

    /// Writes the value of a custom characteristic.
    internal func write(_ characteristic: CharacteristicProtocol,
                        value: DataConvertible,
                        type: CBCharacteristicWriteType = .withResponse,
                        result: @escaping (Result<DataInitializable, Error>) -> Void) {
        guard state == .isPoweredOn else {
            result(.failure(GormssonError.powerOff))
            return
        }

        let request = GattRequest(.write, characteristic: characteristic, result: result)

        guard !isDiscovering else {
            pendingRequests.append(request)
            return
        }

        write(request, value: value, type: type)
    }

    internal func peripheralDidDiscoverCharacteristics() {
        discoveringService -= 1
        if discoveringService <= 0 {
            isDiscovering = false
            didReady?()
            pendingRequests.forEach { request in
                switch request.property {
                case .read:
                    read(request)
                case .notify:
                    notify(request)
                default:
                    break
                }
            }
            pendingRequests.removeAll()
        }
    }

    /// Send a new scan if the first one was too early.
    internal func rescan() {
        if needScan, let block = didDiscover {
            scan(scanServices, options: scanOptions, didDiscoverHandler: block)
            needScan = false
            scanServices = nil
            scanOptions = nil
        }
    }

    internal func cancelCurrent() {
        if let peripheral = current {
            cbManager?.cancelPeripheralConnection(peripheral)
        }
    }

    // MARK: - Private functions

    private func read(_ request: GattRequest, append: Bool = true) {
        guard state == .isPoweredOn else {
            request.result?(.failure(GormssonError.powerOff))
            return
        }

        guard let current = current else {
            request.result?(.failure(GormssonError.deviceUnconnected))
            return
        }

        guard let cbCharacteristic = get(request.characteristic) else {
            request.result?(.failure(GormssonError.characteristicNotFound))
            return
        }

        current.readValue(for: cbCharacteristic)

        if append {
            currentRequests.append(request)
        }
    }

    /// Starts notifications for the value of a characteristic from a request.
    private func notify(_ request: GattRequest) {
        guard state == .isPoweredOn else {
            request.result?(.failure(GormssonError.powerOff))
            return
        }

        guard let current = current else {
            request.result?(.failure(GormssonError.deviceUnconnected))
            return
        }

        guard let cbCharacteristic = get(request.characteristic) else {
            request.result?(.failure(GormssonError.characteristicNotFound))
            return
        }

        guard !cbCharacteristic.isNotifying, !currentRequests.contains(request) else {
            request.result?(.failure(GormssonError.alreadyNotifying))
            return
        }

        current.setNotifyValue(true, for: cbCharacteristic)
        currentRequests.append(request)
    }

    /// Writes the value of a characteristic from a request.
    private func write(_ request: GattRequest,
                       value: DataConvertible,
                       type: CBCharacteristicWriteType = .withResponse) {
        guard state == .isPoweredOn else {
            request.result?(.failure(GormssonError.powerOff))
            return
        }

        guard let current = current else {
            request.result?(.failure(GormssonError.deviceUnconnected))
            return
        }

        guard let cbCharacteristic = get(request.characteristic) else {
            request.result?(.failure(GormssonError.characteristicNotFound))
            return
        }

        current.writeValue(value.toData(),
                           for: cbCharacteristic,
                           type: type)

        if type == .withResponse {
            currentRequests.append(request)
        }
    }
}
