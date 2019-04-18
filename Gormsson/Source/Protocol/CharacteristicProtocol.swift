//
//  CharacteristicProtocol.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 18/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

/// Gormsson protocol for a characteristic.
public protocol CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    var uuid: CBUUID { get }
    /// The service that this characteristic belongs to.
    var service: GattService { get }
    /// The value's format of the characteristic.
    var format: DataInitializable.Type { get }
}
