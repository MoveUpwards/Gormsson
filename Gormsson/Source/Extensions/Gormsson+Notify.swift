//
//  Gormsson+Notify.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation
import Nevanlinna

extension Gormsson {
    /// Starts notifications or indications for the value of a base characteristic.
    public func notify(_ characteristic: GattCharacteristic,
                       success: @escaping (DataInitializable?) -> Void,
                       error: @escaping (Error?) -> Void) {
        notify(characteristic.characteristic, success: success, error: error)
    }

    /// Starts notifications or indications for the value of a base characteristic.
    public func notify(_ characteristic: CharacteristicProtocol,
                       success: @escaping (DataInitializable?) -> Void,
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

    /// Stops notifications or indications for the value of a custom characteristic.
    public func stopNotify(_ characteristic: GattCharacteristic) {
        stopNotify(characteristic.characteristic)
    }

    /// Stops notifications or indications for the value of a custom characteristic.
    public func stopNotify(_ characteristic: CharacteristicProtocol) {
        currentRequests = currentRequests
            .filter({ !($0.property == .notify && $0.characteristic.uuid == characteristic.uuid) })
        pendingRequests = pendingRequests
            .filter({ !($0.property == .notify && $0.characteristic.uuid == characteristic.uuid) })

        guard let cbCharacteristic = get(characteristic), cbCharacteristic.isNotifying else { return }

        current?.setNotifyValue(false, for: cbCharacteristic)
    }
}
