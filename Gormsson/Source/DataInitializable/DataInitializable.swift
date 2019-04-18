//
//  DataInitializable.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

/// Protocol to cast BLE Data to your expected type.
public protocol DataInitializable {
    /// Initialize the object from octets' array.
    init?(with octets: [UInt8])
}

extension Data {
    /// Converts Data to array of 8 bits.
    public var toOctets: [UInt8] {
        return [UInt8](self)
    }
}
