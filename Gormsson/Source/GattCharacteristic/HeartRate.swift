//
//  HeartRate.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 11/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

// MARK: - Characteristics

/// HeartRateMeasurement's characteristic of HeartRate service
internal final class HeartRateMeasurement: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A37")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .heartRate
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return HeartRateMeasurementType.self
    }
}

/// BodySensorLocation's characteristic of HeartRate service
internal final class BodySensorLocation: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A38")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .heartRate
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return BodySensorLocationEnum.self
    }
}

// TODO: Add missing: HeartRateControlPoint
