//
//  TxPowerService.swift
//  Gormsson
//
//  Created by Loïc Griffié on 27/05/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

/// BatteryLevel's characteristic of BatteryService service
internal final class TxPowerLevel: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A07")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .txPower
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return UInt8.self
    }
}
