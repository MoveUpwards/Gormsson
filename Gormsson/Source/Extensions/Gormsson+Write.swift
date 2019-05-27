//
//  Gormsson+Write.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation
import CoreBluetooth
import Nevanlinna

extension Gormsson {
    /// Writes the value of a base characteristic.
    public func write(_ characteristic: GattCharacteristic,
                      value: DataConvertible,
                      type: CBCharacteristicWriteType = .withResponse,
                      result: @escaping (Result<DataInitializable, Error>) -> Void) {
        write(characteristic.characteristic, value: value, type: type, result: result)
    }

    /// Writes the value of a custom characteristic.
    public func write(_ characteristic: CharacteristicProtocol,
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
}
