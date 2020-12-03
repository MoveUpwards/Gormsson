//
//  GattCharacteristic+CharacteristicProtocol.swift
//  Gormsson
//
//  Created by Mac on 03/12/2020.
//  Copyright © 2020 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension GattCharacteristic {
    public func isEqual(to: CharacteristicProtocol) -> Bool {
        return characteristic.uuid == to.uuid
    }

    /// Comparaison between GattCharacteristic and CharacteristicProtocol
    public static func == (lhs: GattCharacteristic, rhs: CharacteristicProtocol) -> Bool {
        return lhs.characteristic.uuid == rhs.uuid
    }
}

extension CharacteristicProtocol {
    /// Comparaison between two CharacteristicProtocol
    public static func == (lhs: CharacteristicProtocol, rhs: CharacteristicProtocol) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    /// Comparaison between CharacteristicProtocol and GattCharacteristic
    public static func == (lhs: CharacteristicProtocol, rhs: GattCharacteristic) -> Bool {
        return lhs.uuid == rhs.characteristic.uuid
    }
}
