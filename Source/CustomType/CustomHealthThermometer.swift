//
//  CustomHealthThermometer.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 18/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation
import Nevanlinna

// MARK: - TemperatureMeasurementTypeEnum

/// TemperatureMeasurementTypeEnum define the values of unit in TemperatureMeasurementType.
public enum TemperatureMeasurementTypeEnum: UInt8, CustomStringConvertible {
    /// Measurement location in armpit
    case armpit = 1
    /// Measurement location on body
    case body
    /// Measurement location on ear lobe
    case ear
    /// Measurement location on finger
    case finger
    /// Measurement location in intestinal tract
    case gastroIntestinalTract
    /// Measurement location in mouth
    case mouth
    /// Measurement location in rectum
    case rectum
    /// Measurement location on toe
    case toe
    /// Measurement location in tympanum
    case tympanum
    /// MeasurementType not supported on the current peripheral.
    case unsupported

    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .armpit:
            return "Armpit"
        case .body:
            return "Body (general)"
        case .ear:
            return "Ear (usually ear lobe)"
        case .finger:
            return "Finger"
        case .gastroIntestinalTract:
            return "Gastro-intestinal Tract"
        case .mouth:
            return "Mouth"
        case .rectum:
            return "Rectum"
        case .toe:
            return "Toe"
        case .tympanum:
            return "Tympanum (ear drum)"
        default:
            return "Reserved for future use"
        }
    }
}

// MARK: - TemperatureMeasurementUnitEnum

/// TemperatureMeasurementUnitEnum define the values of unit in TemperatureMeasurementType.
public enum TemperatureMeasurementUnitEnum: UInt8, CustomStringConvertible {
    /// Measurement in celsius
    case celsius = 0
    /// Measurement in fahrenheit
    case fahrenheit

    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .celsius:
            return "Celsius"
        case .fahrenheit:
            return "Fahrenheit"
        }
    }
}

// MARK: - TemperatureMeasurementType

//swiftlint:disable:next line_length
// See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.temperature_measurement.xml

/// TemperatureMeasurementType define the values of TemperatureMeasurement characteristic.
public final class TemperatureMeasurementType: DataInitializable {
    private let characteristicData: [UInt8]

    /// DataInitializable init.
    required public init(with octets: [UInt8]) {
        characteristicData = octets
    }

    /// Temperature measurement value.
    public var value: Float {
        return Float(bitPattern: UInt32(with: Array(characteristicData[1...4])))
    }

    /// Temperature measurement unit.
    public var unit: TemperatureMeasurementUnitEnum {
        return characteristicData[0].bool(at: 0) ? .celsius : .fahrenheit
    }

    /// Temperature measurement location.
    public var type: TemperatureMeasurementTypeEnum? {
        guard characteristicData[0].bool(at: 2) else { return nil }

        guard characteristicData[0].bool(at: 1) else {
            return TemperatureMeasurementTypeEnum(rawValue: characteristicData[5])
        }

        return TemperatureMeasurementTypeEnum(rawValue: characteristicData[12])
    }

    /// Temperature measurement date.
    public var timestamp: CustomDateTime? {
        guard characteristicData[0].bool(at: 1) else { return nil }

        return CustomDateTime(with: Array(characteristicData[5...11]))
    }
}
