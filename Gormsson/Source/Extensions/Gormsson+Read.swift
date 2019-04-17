//
//  Gormsson+Read.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension Gormsson {
    /// Reads the value of a base characteristic.
    public func read(_ characteristic: GattCharacteristic,
                     success: @escaping (DataInitializable?) -> Void,
                     error: @escaping (Error?) -> Void) {
        read(characteristic.characteristic, success: success, error: error)
    }

    /// Reads the value of a custom characteristic.
    public func read(_ characteristic: CharacteristicProtocol,
                     success: @escaping (DataInitializable?) -> Void,
                     error: @escaping (Error?) -> Void) {
        guard state == .isPoweredOn else {
            error(GormssonError.powerOff)
            return
        }

        let request = GattRequest(.read, characteristic: characteristic, success: success, error: error)

        guard !isDiscovering else {
            pendingRequests.append(request)
            return
        }

        read(request)
    }
}
