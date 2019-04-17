//
//  TemperatureMeasurement.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

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

//swiftlint:disable:next line_length
// See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.temperature_measurement.xml

/// TemperatureMeasurementType define the values of TemperatureMeasurement characteristic.
public class TemperatureMeasurementType: DataInitializable {
    private let characteristicData: [UInt8]

    /// Temperature measurement value.
    public var value: Float {
        return Float(bitPattern: UInt32(with: Array(characteristicData[1...4])))
    }

    /// Temperature measurement unit.
    public var unit: TemperatureMeasurementUnitEnum {
        return characteristicData[0] & 0x01 == 0 ? .celsius : .fahrenheit
    }

    /// Temperature measurement location.
    public var type: TemperatureMeasurementTypeEnum {
        switch characteristicData[0] & 0x02 {
        case 1:
            return .armpit
        case 2:
            return .body
        case 3:
            return .ear
        case 4:
            return .finger
        case 5:
            return .gastroIntestinalTract
        case 6:
            return .mouth
        case 7:
            return .rectum
        case 8:
            return .toe
        case 9:
            return .tympanum
        default:
            return .unsupported
        }
    }

    /// Temperature measurement date.
    public var timestamp: Date? {
        guard characteristicData[0] & 0x2 > 0 else { return nil }

        let dateComponents = DateComponents(calendar: Calendar.current,
                                            timeZone: TimeZone(secondsFromGMT: 0),
                                            year: Int(UInt16(with: Array(characteristicData[5...6]))),
                                            month: Int(characteristicData[7]),
                                            day: Int(characteristicData[8]),
                                            hour: Int(characteristicData[9]),
                                            minute: Int(characteristicData[10]),
                                            second: Int(characteristicData[11]))
        return dateComponents.date
    }

    /// DataInitializable init.
    required public init(with data: Data) {
        characteristicData = [UInt8](data)
    }
}

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
