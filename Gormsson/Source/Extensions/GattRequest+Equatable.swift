//
//  GattRequest+Equatable.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 10/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension GattRequest: Equatable {
    /// To be Equatable.
    internal static func == (lhs: GattRequest, rhs: GattRequest) -> Bool {
        return lhs.characteristic.uuid == rhs.characteristic.uuid && lhs.property == rhs.property
    }
}
