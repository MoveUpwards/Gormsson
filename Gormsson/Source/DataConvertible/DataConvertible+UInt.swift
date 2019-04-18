//
//  DataConvertible+UInt.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension UInt8: DataConvertible {
    public func toData() -> Data {
        /// Return Data of the object.
        return Data(repeating: self, count: 1)
    }
}

//TODO: Add UInt16; UInt and UInt64
