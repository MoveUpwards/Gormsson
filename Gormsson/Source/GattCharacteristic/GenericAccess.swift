//
//  GenericAccess.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 09/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

/// DeviceName's characteristic of GenericAccess service
internal final class DeviceName: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A00")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .genericAccess
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return String.self
    }
}

// TODO: Add missing: Appearance, Peripheral Privacy Flag, Reconnection Address
//      and Peripheral Preferred Connection Parameters
