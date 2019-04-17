//
//  HeartRate.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 11/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

internal final class HeartRateMeasurement: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A37")
    }

    public var service: GattService {
        return .heartRate
    }

    public var format: DataInitializable.Type {
        return HeartRateMeasurementType.self
    }
}

internal final class BodySensorLocation: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A38")
    }

    public var service: GattService {
        return .heartRate
    }

    public var format: DataInitializable.Type {
        return BodySensorLocationEnum.self
    }
}

// TODO: Add missing: HeartRateControlPoint

public enum BodySensorLocationEnum: UInt8, CustomStringConvertible {
    case other = 0
    case chest
    case wrist
    case finger
    case hand
    case earLobe
    case foot

    case unknown

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

public enum SensorContactStatus: UInt8 {
    case contactFail = 2
    case contactSuccess = 3

    case unsupported
}

// See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
public class HeartRateMeasurementType {
    private let characteristicData: [UInt8]

    public var heartRateValue: UInt16 {
        return characteristicData[0] & 0x01 == 0 ?
            UInt16(characteristicData[1]) :
            (UInt16(characteristicData[1]) << 8) + UInt16(characteristicData[2])
    }

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

    public var energyExpended: UInt16? {
        return characteristicData[0] & 0x08 == 0 ? nil : UInt16(characteristicData[3])
    }

    public var rrInterval: UInt16? {
        return characteristicData[0] & 0x10 == 0 ? nil : UInt16(characteristicData[4])
    }

    required public init(with data: Data) {
        characteristicData = [UInt8](data)
    }
}

extension HeartRateMeasurementType: DataInitializable {
}
