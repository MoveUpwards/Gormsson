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
    public var batteryLevel: Characteristic<UInt8> {
        return Characteristic(peripheral: self, service: "180F", uuid: "2A19", properties: [.read, .notify])
    }
}
