//
//  DataInitializable+Int.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension Int8: DataInitializable {
    /// Initialize the object from Data
    public init?(with data: Data) {
        var intValue = Int8(0)
        for (index, element) in [UInt8](data).enumerated() {
            intValue += Int8(element) << (8 * index)
        }
        self = intValue
    }
}

//TODO: Add Int16; Int and Int64
