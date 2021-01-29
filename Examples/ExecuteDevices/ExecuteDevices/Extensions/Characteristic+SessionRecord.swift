//
//  Characteristic+SessionRecord.swift
//  ExecuteDevices
//
//  Created by Mac on 23/11/2020.
//

import Foundation
import CoreBluetooth
import Gormsson
import Nevanlinna

public final class SessionRecord: CharacteristicProtocol {
    public init() { }

    public var service: GattService {
        return GattService.custom("0BD51666-E7CB-469B-8E4D-2742AAAA0200")
    }

    public var uuid: CBUUID {
        return CBUUID(string: "E7ADD780-B042-4876-AAE1-1128AAAA0203")
    }

    public var format: DataInitializable.Type {
        return SessionRecordEnum.self
    }
}

/// SessionErrorEnum define the Session error values.
public enum SessionRecordEnum: UInt8, DataInitializable, DataConvertible {
    /// Session record stop.
    case stop = 0
    /// Session record start
    case start

    public init?(with octets: [UInt8]) {
        guard let value = SessionRecordEnum(rawValue: UInt8(with: octets)) else {
            return nil
        }
        self = value
    }

    public func toData() -> Data {
        return Data(repeating: rawValue, count: 1)
    }
}
