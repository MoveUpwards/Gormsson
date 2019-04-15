//
//  DataInitializable+HeartRate.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation


extension BodySensorLocationEnum: DataInitializable {
    public init?(with data: Data) {
        var intValue = UInt8(0)
        for (index, element) in [UInt8](data).enumerated() {
            intValue += UInt8(element) << (8 * index)
        }
        guard let value = BodySensorLocationEnum(rawValue: intValue) else {
            return nil
        }
        self = value
    }
}
