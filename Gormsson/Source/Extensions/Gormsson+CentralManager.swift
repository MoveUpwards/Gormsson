//
//  Gormsson+CentralManager.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 12/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

extension Gormsson: CBCentralManagerDelegate {
    /// Invoked when the central manager’s state is updated.
    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
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

    /// Invoked when the central manager discovers a peripheral while scanning.
    open func centralManager(_ central: CBCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               advertisementData: [String: Any],
                               rssi RSSI: NSNumber) {
        didDiscover?(peripheral, GattAdvertisement(with: advertisementData, rssi: RSSI.intValue))
    }

    /// Invoked when an existing connection with a peripheral is torn down.
    open func centralManager(_ central: CBCentralManager,
                               didDisconnectPeripheral peripheral: CBPeripheral,
                               error: Error?) {
        didDisconnect?(peripheral, error)
        cleanPeripheral()
        current = nil
    }

    /// Invoked when a connection is successfully created with a peripheral.
    open func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        didConnect?(peripheral)
        current?.discoverServices(nil)
    }

    /// Invoked when a connection with a peripheral did fail.
    open func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        didFailConnect?(peripheral, error)
        cleanPeripheral()
        current = nil
    }
}
