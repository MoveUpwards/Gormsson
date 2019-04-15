//
//  GenericAccess.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 09/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth

internal final class DeviceName: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A00")
    }

    public var service: GattService {
        return .genericAccess
    }

    public var format: DataInitializable.Type {
        return String.self
    }
}

// TODO: Add missing: Appearance, Peripheral Privacy Flag, Reconnection Address, Peripheral Preferred Connection Parameters
