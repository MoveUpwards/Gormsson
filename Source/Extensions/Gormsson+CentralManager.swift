//
//  Gormsson+CentralManager.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 12/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

extension CentralManager: CBCentralManagerDelegate {
    /// Invoked when the central manager’s state is updated.
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        updateState(with: central.state)
    }

    /// Invoked when the central manager discovers a peripheral while scanning.
    internal func centralManager(_ central: CBCentralManager,
                                 didDiscover peripheral: CBPeripheral,
                                 advertisementData: [String: Any],
                                 rssi RSSI: NSNumber) {
        let advertisement = GattAdvertisement(with: advertisementData, rssi: RSSI.intValue)
        didDiscover?(.success(GormssonPeripheral(peripheral: peripheral, advertisement: advertisement)))

        if nil != didUpdate { // Only if we need it
            if let index = currentPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
                currentPeripherals[index] = GormssonPeripheral(peripheral: peripheral, advertisement: advertisement)
            } else {
                currentPeripherals.append(GormssonPeripheral(peripheral: peripheral, advertisement: advertisement))
            }
        }
    }

    /// Invoked when an existing connection with a peripheral is torn down.
    internal func centralManager(_ central: CBCentralManager,
                                 didDisconnectPeripheral peripheral: CBPeripheral,
                                 error: Error?) {
        connectHandlers[peripheral.identifier]?.didDisconnect?(error)
        remove(peripheral)
    }

    /// Invoked when a connection is successfully created with a peripheral.
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectHandlers[peripheral.identifier]?.didConnect?()
        peripheral.discoverServices(nil)
    }

    /// Invoked when a connection with a peripheral did fail.
    internal func centralManager(_ central: CBCentralManager,
                                 didFailToConnect peripheral: CBPeripheral,
                                 error: Error?) {
        connectHandlers[peripheral.identifier]?.didFailConnect?(error ?? GormssonError.unexpectedNilError)
        remove(peripheral)
    }

    // MARK: - Private functions

    /// Remove current peripheral and send disconnect error to all pending request.
    private func remove(_ peripheral: CBPeripheral) {
        let currentPeripheral: (GattRequest) -> Bool = { $0.peripheral == peripheral }
        currentRequests
            .filter(currentPeripheral)
            .forEach { $0.result?(.failure(GormssonError.deviceDisconnected)) }
        currentRequests
            .removeAll(where: currentPeripheral)

        pendingRequests
            .filter(currentPeripheral)
            .forEach { $0.result?(.failure(GormssonError.deviceDisconnected)) }
        pendingRequests
            .removeAll(where: currentPeripheral)

        connectHandlers[peripheral.identifier] = nil
    }
}
