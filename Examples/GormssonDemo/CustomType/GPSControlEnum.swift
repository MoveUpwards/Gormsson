//
//  GPSControlEnum.swift
//  GormssonDemo
//
//  Created by Loïc GRIFFIE on 19/06/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import Foundation
import Nevanlinna

public enum GPSControlEnum: UInt8, DataInitializable, DataConvertible {
    case stop = 0
    case start

    /// DataInitializable init.
    public init?(with octets: [UInt8]) {
        guard let value = GPSControlEnum(rawValue: UInt8(with: octets)) else {
            return nil
        }
        self = value
    }

    public var data: Data {
        return Data(repeating: rawValue, count: 1)
    }
}
