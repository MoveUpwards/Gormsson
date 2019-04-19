//
//  BatteryService.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 08/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

/// BatteryLevel's characteristic of BatteryService service
internal final class BatteryLevel: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A19")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .batteryService
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return UInt8.self
    }
}
