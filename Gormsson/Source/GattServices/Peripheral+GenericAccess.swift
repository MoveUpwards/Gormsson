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
    public var deviceName: Characteristic<String> {
        return Characteristic(peripheral: self, service: "1800", uuid: "2A00", properties: [.read, .write])
    }
}
