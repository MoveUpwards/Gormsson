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
        didDiscover?(peripheral, GattAdvertisement(with: advertisementData, rssi: RSSI.intValue))
    }

    /// Invoked when an existing connection with a peripheral is torn down.
    internal func centralManager(_ central: CBCentralManager,
                                 didDisconnectPeripheral peripheral: CBPeripheral,
                                 error: Error?) {
        didDisconnect?(peripheral, error)
        cleanPeripheral()
        current = nil
        removeRequests()
    }

    /// Invoked when a connection is successfully created with a peripheral.
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        didConnect?(peripheral)
        current?.discoverServices(nil)
    }

    /// Invoked when a connection with a peripheral did fail.
    internal func centralManager(_ central: CBCentralManager,
                                 didFailToConnect peripheral: CBPeripheral,
                                 error: Error?) {
        didFailConnect?(peripheral, error)
        cleanPeripheral()
        current = nil
        removeRequests()
    }

    internal func disconnect() {
        cancelCurrent()
    }

    internal func cleanPeripheral() {
        currentRequests.forEach { req in
            req.result?(.failure(GormssonError.deviceUnconnected))
        }
        pendingRequests.forEach { req in
            req.result?(.failure(GormssonError.deviceUnconnected))
        }
    }

    private func removeRequests() {
        currentRequests.removeAll()
        pendingRequests.removeAll()
    }
}
