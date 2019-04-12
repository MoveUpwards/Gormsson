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

    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateNotificationStateFor characteristic: CBCharacteristic,
                           error: Error?) {
        print("Update notification:", characteristic)
        print("Update notification:", characteristic.isNotifying)

        currentRequests.filter({ $0.characteristic.uuid == characteristic.uuid })
            .filter({ characteristic.properties.contains($0.property) && $0.property == .notify })
            .forEach { request in
                error != nil ? request.error?(error) : read(request, append: false)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral,
                           didWriteValueFor characteristic: CBCharacteristic,
                           error: Error?) {
        var deletedRequest = [GattRequest]()

        currentRequests.filter({ $0.characteristic.uuid == characteristic.uuid })
            .filter({ characteristic.properties.contains($0.property) && $0.property == .write })
            .forEach { request in
                if error != nil {
                    request.error?(error)
                } else if let block = request.success as? () -> Void {
                    block()
                }

                deletedRequest.append(request)
        }

        currentRequests = currentRequests.filter({ !deletedRequest.contains($0) })
    }

    // MARK: - Private functions

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func compute(_ request: GattRequest, with characteristic: CBCharacteristic) {
        guard let data = characteristic.value else { return }

        switch request.characteristic.format {
        case is Int8.Type:
            if let block = request.success as? (Int8?) -> Void {
                var intValue = Int8(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += Int8(element) << (8 * index)
                }
                block(intValue)
                return
            }
        case is UInt8.Type:
            if let block = request.success as? (UInt8?) -> Void {
                var intValue = UInt8(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += UInt8(element) << (8 * index)
                }
                block(intValue)
                return
            }
        case is UInt16.Type:
            if let block = request.success as? (UInt16?) -> Void {
                var intValue = UInt16(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += UInt16(element) << (8 * index)
                }
                block(intValue)
                return
            }
        case is UInt.Type:
            if let block = request.success as? (UInt?) -> Void {
                var intValue = UInt(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += UInt(element) << (8 * index)
                }
                block(intValue)
                return
            }
        case is UInt64.Type:
            if let block = request.success as? (UInt64?) -> Void {
                var intValue = UInt64(0)
                for (index, element) in [UInt8](data).enumerated() {
                    intValue += UInt64(element) << (8 * index)
                }
                block(intValue)
                return
            }
        case is String.Type:
            if let block = request.success as? (String?) -> Void {
                block(String(bytes: [UInt8](data), encoding: .utf8))
                return
            }
        case is HeartRateMeasurementType.Type:
            if let block = request.success as? (HeartRateMeasurementType?) -> Void {
                block(HeartRateMeasurementType(with: data))
                return
            }
        default:
            print("UNKNOWN TYPE")
        }

        request.error?(GormssonError.uncastableValue)
    }
}
