//
//  GattRequest.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 09/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth

/// A class that represent a request on a characteristic.
internal final class GattRequest {
    /// The property of the characteristic.
    internal var property: CBCharacteristicProperties
    /// The Gormsson's characteristic.
    internal var characteristic: CharacteristicProtocol
    /// The block to call on succeed request.
    internal var block: Any?
    /// The value to write.
    internal var value: Any?
    /// The state to know if the request was process or not.
    internal var isPending: Bool

    /// Init with some default values.
    internal init(_ property: CBCharacteristicProperties,
                  characteristic: CharacteristicProtocol,
                  block: Any? = nil,
                  value: Any? = nil,
                  isPending: Bool = true) {
        self.property = property
        self.characteristic = characteristic
        self.block = block
        self.value = value
        self.isPending = isPending
    }
}

extension GattRequest: Equatable {
    /// To be Equatable.
    internal static func == (lhs: GattRequest, rhs: GattRequest) -> Bool {
        return lhs.characteristic.uuid == rhs.characteristic.uuid && lhs.property == rhs.property
    }
}
