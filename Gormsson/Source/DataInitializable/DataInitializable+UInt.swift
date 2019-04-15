//
//  DataInitializable+UInt.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension UInt8: DataInitializable {
    /// Initialize the object from Data
    public init?(with data: Data) {
        var intValue = UInt8(0)
        for (index, element) in [UInt8](data).enumerated() {
            intValue += UInt8(element) << (8 * index)
        }
        self = intValue
    }
}

extension UInt16: DataInitializable {
    /// Initialize the object from Data
    public init?(with data: Data) {
        var intValue = UInt16(0)
        for (index, element) in [UInt8](data).enumerated() {
            intValue += UInt16(element) << (8 * index)
        }
        self = intValue
    }
}

extension UInt: DataInitializable {
    /// Initialize the object from Data
    public init?(with data: Data) {
        var intValue = UInt(0)
        for (index, element) in [UInt8](data).enumerated() {
            intValue += UInt(element) << (8 * index)
        }
        self = intValue
    }
}

extension UInt64: DataInitializable {
    /// Initialize the object from Data
    public init?(with data: Data) {
        var intValue = UInt64(0)
        for (index, element) in [UInt8](data).enumerated() {
            intValue += UInt64(element) << (8 * index)
        }
        self = intValue
    }
}
