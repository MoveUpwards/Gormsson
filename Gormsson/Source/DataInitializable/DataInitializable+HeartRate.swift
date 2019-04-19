//
//  DataInitializable+HeartRate.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation
import Nevanlinna

extension BodySensorLocationEnum: DataInitializable {
    /// DataInitializable init.
    public init?(with octets: [UInt8]) {
        guard let value = BodySensorLocationEnum(rawValue: UInt8(with: octets)) else {
            return nil
        }
        self = value
    }
}
