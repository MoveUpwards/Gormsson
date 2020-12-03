//
//  GattCharacteristic+CharacteristicProtocol.swift
//  Gormsson
//
//  Created by Mac on 03/12/2020.
//  Copyright © 2020 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension GattCharacteristic {
    /// Comparaison between GattCharacteristic and CharacteristicProtocol
    public func isEqual(to: CharacteristicProtocol) -> Bool {
        return characteristic.uuid == to.uuid
    }
}

extension CharacteristicProtocol {
    /// Comparaison between two CharacteristicProtocol
    public func isEqual(to: CharacteristicProtocol) -> Bool {
        return uuid == to.uuid
    }

    /// Comparaison between CharacteristicProtocol and GattCharacteristic
    public func isEqual(to: GattCharacteristic) -> Bool {
        return uuid == to.characteristic.uuid
    }
}
