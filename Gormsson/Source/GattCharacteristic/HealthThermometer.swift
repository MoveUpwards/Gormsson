//
//  TemperatureMeasurement.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

internal final class TemperatureMeasurement: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A1C")
    }

    public var service: GattService {
        return .healthThermometer
    }

    public var format: DataInitializable.Type {
        return TemperatureMeasurementType.self
    }
}

public enum TemperatureMeasurementTypeEnum: UInt8, CustomStringConvertible {
    case armpit = 1
    case body
    case ear
    case finger
    case gastroIntestinalTract
    case mouth
    case rectum
    case toe
    case tympanum

    case unsupported

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

public enum TemperatureMeasurementUnitEnum: UInt8, CustomStringConvertible {
    case celsius = 0
    case fahrenheit

    public var description: String {
        switch self {
        case .celsius:
            return "Celsius"
        case .fahrenheit:
            return "Fahrenheit"
        }
    }
}

// See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.temperature_measurement.xml
public class TemperatureMeasurementType {
    private let characteristicData: [UInt8]

    public var value: Float {
        let bitValue = UInt32(characteristicData[1] << 24) +
            UInt32(characteristicData[2] << 16) +
            UInt32(characteristicData[3] << 8) +
            UInt32(characteristicData[4])
        return Float(bitPattern: bitValue)
    }

    public var unit: TemperatureMeasurementUnitEnum {
        return characteristicData[0] & 0x01 == 0 ? .celsius : .fahrenheit
    }

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

    public var timestamp: Date? {
        guard characteristicData[0] & 0x2 > 0 else { return nil }

        let dateComponents = DateComponents(calendar: Calendar.current,
                                            timeZone: TimeZone(secondsFromGMT: 0),
                                            year: Int(UInt16(characteristicData[5]) + UInt16(characteristicData[6] << 8)),
                                            month: Int(characteristicData[7]),
                                            day: Int(characteristicData[8]),
                                            hour: Int(characteristicData[9]),
                                            minute: Int(characteristicData[10]),
                                            second: Int(characteristicData[11]))
        return dateComponents.date
    }

    required public init(with data: Data) {
        characteristicData = [UInt8](data)
    }
}

extension TemperatureMeasurementType: DataInitializable { }
