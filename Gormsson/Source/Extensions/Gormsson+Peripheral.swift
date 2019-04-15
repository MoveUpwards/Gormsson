//
//  Gormsson+Peripheral.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 12/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

extension Gormsson: CBPeripheralDelegate {
    /// Invoked when you discover the peripheral’s available services.
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        discoveringService = services.count
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    /// Invoked when you discover the characteristics of a specified service.
    public func peripheral(_ peripheral: CBPeripheral,
                           didDiscoverCharacteristicsFor service: CBService,
                           error: Error?) {
        discoveringService -= 1
        if discoveringService <= 0 {
            isDiscovering = false
            pendingRequests.forEach { request in
                switch request.property {
                case .read:
                    read(request)
                case .notify:
                    notify(request)
                case .write:
                    write(request)
                default:
                    break
                }
            }
        }
    }

    /// Invoked when you retrieve a specified characteristic’s value, or when the peripheral device notifies
    /// your app that the characteristic’s value has changed.
    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateValueFor characteristic: CBCharacteristic,
                           error: Error?) {
        var deletedRequest = [GattRequest]()

        currentRequests.filter({ $0.characteristic.uuid == characteristic.uuid })
            .filter({ characteristic.properties.contains($0.property) })
            .forEach { request in
                error != nil ? request.error?(error) : compute(request, with: characteristic)

                switch request.property {
                case .read:
                    deletedRequest.append(request)
                default:
                    break
                }
        }

        currentRequests = currentRequests.filter({ !deletedRequest.contains($0) })
    }

    /// Invoked when the peripheral receives a request to start or stop providing notifications for
    /// a specified characteristic’s value.
    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateNotificationStateFor characteristic: CBCharacteristic,
                           error: Error?) {
        currentRequests.filter({ $0.characteristic.uuid == characteristic.uuid })
            .filter({ characteristic.properties.contains($0.property) && $0.property == .notify })
            .forEach { request in
                error != nil ? request.error?(error) : read(request, append: false)
        }
    }

    /// Invoked when you write data to a characteristic’s value.
    public func peripheral(_ peripheral: CBPeripheral,
                           didWriteValueFor characteristic: CBCharacteristic,
                           error: Error?) {
        var deletedRequest = [GattRequest]()

        currentRequests.filter({ $0.characteristic.uuid == characteristic.uuid })
            .filter({ characteristic.properties.contains($0.property) && $0.property == .write })
            .forEach { request in
                error != nil ? request.error?(error) : compute(request, with: characteristic)

                deletedRequest.append(request)
        }

        currentRequests = currentRequests.filter({ !deletedRequest.contains($0) })
    }

    // MARK: - Private functions

    private func compute(_ request: GattRequest, with characteristic: CBCharacteristic) {
        guard let data = characteristic.value else {
            request.success?(nil)
            return
        }

        let value = request.characteristic.format.init(with: data)
        request.success?(value)
    }
}
