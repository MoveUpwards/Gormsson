//
//  GPSArrayType.swift
//  GormssonDemo
//
//  Created by Loïc GRIFFIE on 19/06/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import Foundation
import Nevanlinna

public final class GPSArrayType: DataInitializable, DataConvertible {
    private let characteristicData: [UInt8]

    /// DataInitializable init.
    required public init(with octets: [UInt8]) {
        characteristicData = octets
    }

    /// Return Data of the object.
    public func toData() -> Data {
        return Data(characteristicData)
    }
}
