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
    /// The block to call on succeed request.
    internal var success: ((DataInitializable?) -> Void)?
    /// The block to call on error request.
    internal var error: ((Error?) -> Void)?
//    /// The value to write.
//    internal var value: DataConvertible?

    /// Init with some default values.
    internal init(_ property: CBCharacteristicProperties,
                  characteristic: CharacteristicProtocol,
                  success: ((DataInitializable?) -> Void)? = nil,
                  error: ((Error?) -> Void)? = nil/*,
                  value: DataConvertible? = nil*/) {
        self.property = property
        self.characteristic = characteristic
        self.success = success
        self.error = error
//        self.value = value
    }
}

extension GattRequest: Equatable {
    /// To be Equatable.
    internal static func == (lhs: GattRequest, rhs: GattRequest) -> Bool {
        return lhs.characteristic.uuid == rhs.characteristic.uuid && lhs.property == rhs.property
    }
}
