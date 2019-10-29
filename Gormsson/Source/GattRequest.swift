//
//  GattRequest.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 09/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

/// A class that represent a request on a characteristic.
internal final class GattRequest {
    /// The property of the characteristic.
    internal var property: CBCharacteristicProperties
    /// The Gormsson's characteristic.
    internal var characteristic: CharacteristicProtocol
    /// The result
    internal var result: ((Result<DataInitializable, Error>) -> Void)?

    /// Init with some default values.
    internal init(_ property: CBCharacteristicProperties,
                  characteristic: CharacteristicProtocol,
                  result: ((Result<DataInitializable, Error>) -> Void)? = nil) {
        self.property = property
        self.characteristic = characteristic
        self.result = result
    }
}
