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

// MARK: - Values types and classes

/// BodySensorLocationEnum define the values of BodySensorLocation characteristic.
public enum BodySensorLocationEnum: UInt8, CustomStringConvertible {
    /// Body sensor on other position (unknonw or undefined).
    case other = 0
    /// Body sensor on the chest.
    case chest
    /// Body sensor on the wrist.
    case wrist
    /// Body sensor on the finger.
    case finger
    /// Body sensor on the hand.
    case hand
    /// Body sensor on the ear lobe.
    case earLobe
    /// Body sensor on the foot.
    case foot
    /// Location not supported on the current peripheral.
    case unsupported

    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .other:
            return "Other"
        case .chest:
            return "Chest"
        case .wrist:
            return "Wrist"
        case .finger:
            return "Finger"
        case .hand:
            return "Hand"
        case .earLobe:
            return "Ear Lobe"
        case .foot:
            return "Foot"
        default:
            return "Reserved for future use"
        }
    }
}

//swiftlint:disable:next line_length
// See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml

/// HeartRateMeasurementType define the values of HeartRateMeasurement characteristic.
public class HeartRateMeasurementType: DataInitializable {
    private let characteristicData: [UInt8]

    /// Current heart rate value.
    public var heartRateValue: UInt16 {
        return characteristicData[0] & 0x01 == 0 ?
            UInt16(characteristicData[1]) :
            UInt16(with: Array(characteristicData[1...2]))
    }

    /// Define the current status of the sensor contact.
    public var sensorContactStatus: SensorContactStatus {
        switch characteristicData[0] & 0x06 {
        case 2:
            return .contactFail
        case 3:
            return .contactSuccess
        default:
            return .unsupported
        }
    }

    /// The current energy extended in Joule
    public var energyExtended: UInt16? {
        guard  characteristicData[0] & 0x08 > 0 else { return nil }

        var firstIndex = 2 // 0 for Flags and 1 for HRM
        if characteristicData[0] & 0x01 > 0 {
            firstIndex += 1 // HRM will be 1 octet more
        }

        return UInt16(with: Array(characteristicData[firstIndex...firstIndex+1]))
    }

    /// The current RR-interval in 1/1024s.
    public var rrInterval: UInt16? {
        guard  characteristicData[0] & 0x10 > 0 else { return nil }

        var firstIndex = 2 // 0 for Flags and 1 for HRM
        if characteristicData[0] & 0x01 > 0 {
            firstIndex += 1 // HRM will be 1 octet more
        }
        if characteristicData[0] & 0x08 > 0 {
            firstIndex += 2 // EnergyExtended will be 2 octets
        }

        return UInt16(with: Array(characteristicData[firstIndex...firstIndex+1]))
    }

    /// DataInitializable init.
    required public init(with octets: [UInt8]) {
        characteristicData = octets
    }
}

/// SensorContactStatus define the values of sensorContactStatus in HeartRateMeasurementType.
public enum SensorContactStatus: UInt8 {
    /// No contact found.
    case contactFail = 2
    /// Contact is successful.
    case contactSuccess = 3
    /// Sensor contact not supported.
    case unsupported
}
