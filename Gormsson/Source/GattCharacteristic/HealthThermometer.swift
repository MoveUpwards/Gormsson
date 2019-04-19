//
//  TemperatureMeasurement.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

// MARK: - Characteristics

/// TemperatureMeasurement's characteristic of healthThermometer service
internal final class TemperatureMeasurement: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A1C")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .healthThermometer
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return TemperatureMeasurementType.self
    }
}
