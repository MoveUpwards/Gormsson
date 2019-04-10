//
//  BatteryService.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 08/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth

internal final class BatteryLevel: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A19")
    }

    public var service: GattService {
        return .batteryService
    }

    public var format: Any.Type {
        return UInt8.self
    }
}
