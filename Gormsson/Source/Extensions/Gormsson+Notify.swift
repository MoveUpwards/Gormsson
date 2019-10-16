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
                       result: @escaping (Result<DataInitializable, Error>) -> Void) {
        notify(characteristic.characteristic, result: result)
    }

    /// Starts notifications or indications for the value of a base characteristic.
    public func notify(_ characteristic: CharacteristicProtocol,
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
    public func stopNotify(_ characteristic: GattCharacteristic) {
        stopNotify(characteristic.characteristic)
    }

    /// Stops notifications or indications for the value of a custom characteristic.
    public func stopNotify(_ characteristic: CharacteristicProtocol) {
        guard let cbCharacteristic = get(characteristic), cbCharacteristic.isNotifying else { return }

        current?.setNotifyValue(false, for: cbCharacteristic)
    }
}
