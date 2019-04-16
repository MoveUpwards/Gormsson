//
//  Gormsson+Write.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension Gormsson {
    /// Writes the value of a base characteristic.
    public func write(_ characteristic: GattCharacteristic,
                      value: DataConvertible,
                      success: @escaping (DataInitializable?) -> Void,
                      error: @escaping (Error?) -> Void) {
        write(characteristic.characteristic, value: value, success: success, error: error)
    }

    /// Writes the value of a custom characteristic.
    public func write(_ characteristic: CharacteristicProtocol,
                      value: DataConvertible,
                      success: @escaping (DataInitializable?) -> Void,
                      error: @escaping (Error?) -> Void) {
        guard state == .isPoweredOn else {
            error(GormssonError.powerOff)
            return
        }

        let request = GattRequest(.write,
                                  characteristic: characteristic,
                                  success: success,
                                  error: error,
                                  value: value)

        guard !isDiscovering else {
            pendingRequests.append(request)
            return
        }

        write(request)
    }
}
