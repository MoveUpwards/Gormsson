//
//  DataConvertible.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

/// Protocol to cast your own type to BLE Data.
public protocol DataConvertible {
    /// Return Data of the object.
    func toData() -> Data
}
