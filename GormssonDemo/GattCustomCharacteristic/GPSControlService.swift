//
//  GPSControlService.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 08/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth
import Gormsson
import Nevanlinna

public let gpsControlService = GattService.custom("C94E7734-F70C-4B96-BB48-F1E3CB95F79E")

public enum GPSControlEnum: UInt8 {
    case stop = 0
    case start
}

extension GPSControlEnum: DataInitializable {
    /// DataInitializable init.
    public init?(with octets: [UInt8]) {
        guard let value = GPSControlEnum(rawValue: UInt8(with: octets)) else {
            return nil
        }
        self = value
    }
}

extension GPSControlEnum: DataConvertible {
    public func toData() -> Data {
        return Data(repeating: rawValue, count: 1)
    }
}

public final class GPSControl: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "C94E0001-F70C-4B96-BB48-F1E3CB95F79E")
    }

    public var service: GattService {
        return gpsControlService
    }

    public var format: DataInitializable.Type {
        return GPSControlEnum.self
    }
}

public final class GPSStatus: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "C94E0002-F70C-4B96-BB48-F1E3CB95F79E")
    }

    public var service: GattService {
        return gpsControlService
    }

    public var format: DataInitializable.Type {
        return UInt8.self
    }
}

public final class GPSSessionCount: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "C94E0003-F70C-4B96-BB48-F1E3CB95F79E")
    }

    public var service: GattService {
        return gpsControlService
    }

    public var format: DataInitializable.Type {
        return UInt.self
    }
}

public final class GPSFreeMemory: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "C94E0004-F70C-4B96-BB48-F1E3CB95F79E")
    }

    public var service: GattService {
        return gpsControlService
    }

    public var format: DataInitializable.Type {
        return UInt.self
    }
}

public final class GPSWipeMemory: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "C94E0005-F70C-4B96-BB48-F1E3CB95F79E")
    }

    public var service: GattService {
        return gpsControlService
    }

    public var format: DataInitializable.Type {
        return UInt.self
    }
}

public final class GPSTimezone: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "C94E0006-F70C-4B96-BB48-F1E3CB95F79E")
    }

    public var service: GattService {
        return gpsControlService
    }

    public var format: DataInitializable.Type {
        return Int8.self
    }
}
