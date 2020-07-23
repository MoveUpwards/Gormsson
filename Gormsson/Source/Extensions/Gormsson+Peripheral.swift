//
//  Gormsson+Peripheral.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 12/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

extension PeripheralManager: CBPeripheralDelegate {
    /// Invoked when you discover the peripheral’s available services.
    internal func peripheral(_ peripheral: CBPeripheral,
                             didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        manager?.connectHandlers[peripheral.identifier]?.remainingServices = services.count
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    /// Invoked when you discover the characteristics of a specified service.
    internal func peripheral(_ peripheral: CBPeripheral,
                             didDiscoverCharacteristicsFor service: CBService,
                             error: Error?) {
        manager?.didDiscoverCharacteristics(on: peripheral)
    }

    /// Invoked when you retrieve a specified characteristic’s value, or when the peripheral device notifies
    /// your app that the characteristic’s value has changed.
    internal func peripheral(_ peripheral: CBPeripheral,
                             didUpdateValueFor characteristic: CBCharacteristic,
                             error: Error?) {
        if characteristic.isNotifying {
            requestNotify(for: peripheral, with: characteristic, error: error)
        }
        request(.read, for: peripheral, with: characteristic, error: error)
    }

    /// Invoked when the peripheral receives a request to start or stop providing notifications for
    /// a specified characteristic’s value.
    internal func peripheral(_ peripheral: CBPeripheral,
                             didUpdateNotificationStateFor characteristic: CBCharacteristic,
                             error: Error?) {
        let reqFilter = filter(for: characteristic, and: .notify)

        if let error = error {
            manager?.currentRequests.filter(reqFilter).forEach { request in
                request.result?(.failure(error))
            }
            return
        }

        guard !characteristic.isNotifying else { return } // No error and isNotifying, all good.

        // Notify all requests that the characteristic notification is ended
        manager?.currentRequests.filter(reqFilter).forEach { request in
            request.result?(.failure(GormssonError.stopNotifying))
        }

        // Remove all unused request
        if let filteredRequest = manager?.currentRequests
            .filter({ !($0.property == .notify && $0.characteristic.uuid == characteristic.uuid) }) {
            manager?.currentRequests = filteredRequest
        }
    }

    /// Invoked when you write data to a characteristic’s value.
    internal func peripheral(_ peripheral: CBPeripheral,
                             didWriteValueFor characteristic: CBCharacteristic,
                             error: Error?) {
        request(.write, for: peripheral, with: characteristic, error: error)
    }

    // MARK: - Private functions

    private func requestNotify(for peripheral: CBPeripheral,
                               with characteristic: CBCharacteristic,
                               error: Error?) {
        let reqFilter = filter(for: characteristic, and: .notify)
        manager?.currentRequests.filter(reqFilter).forEach { request in
            if let error = error {
                request.result?(.failure(error))
            } else {
                compute(request, for: characteristic)
            }
        }
    }

    private func request(_ type: CBCharacteristicProperties,
                         for peripheral: CBPeripheral,
                         with characteristic: CBCharacteristic,
                         error: Error?) {
        let reqFilter = filter(for: characteristic, and: type)
        guard let request = manager?.currentRequests.first(where: reqFilter) else { return }

        manager?.currentRequests.removeAll(where: { $0 === request })

        guard let error = error else {
            compute(request, for: characteristic)
            return
        }

        request.result?(.failure(error))
    }

    private func compute(_ request: GattRequest, for characteristic: CBCharacteristic) {
        guard let data = characteristic.value else {
            request.result?(.success(Empty()))
            return
        }

        guard let value = request.characteristic.format.init(with: data.toOctets) else {
            request.result?(.failure(GormssonError.uncastableValue))
            return
        }

        request.result?(.success(value))
    }

    private func filter(for characteristic: CBCharacteristic,
                        and property: CBCharacteristicProperties) -> (GattRequest) -> Bool {
        return { $0.characteristic.uuid == characteristic.uuid &&
            characteristic.properties.contains($0.property) && $0.property == property }
    }
}
