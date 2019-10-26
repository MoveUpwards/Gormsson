//
//  Gormsson+Read.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation
import Nevanlinna

extension Gormsson {
    /// Reads the value of a base characteristic.
    open func read(_ characteristic: GattCharacteristic,
                     result: @escaping (Result<DataInitializable, Error>) -> Void) {
        read(characteristic.characteristic, result: result)
    }

    /// Reads the value of a custom characteristic.
    open func read(_ characteristic: CharacteristicProtocol,
                     result: @escaping (Result<DataInitializable, Error>) -> Void) {
        guard state == .isPoweredOn else {
            result(.failure(GormssonError.powerOff))
            return
        }

        let request = GattRequest(.read, characteristic: characteristic, result: result)

        guard !isDiscovering else {
            pendingRequests.append(request)
            return
        }

        read(request)
    }
}
