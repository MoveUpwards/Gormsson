//
//  Peripheral+BatteryService.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 29/03/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation
import RxBluetoothKit

extension Peripheral {
    public var txPowerLevel: Characteristic<Int8> {
        return Characteristic(peripheral: self, service: "1804", uuid: "2A07")
    }
}
