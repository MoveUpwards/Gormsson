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
    public var manufacturerName: Characteristic<String> {
        return Characteristic(peripheral: self, service: "180A", uuid: "2A29")
    }

    public var modelNumber: Characteristic<String> {
        return Characteristic(peripheral: self, service: "180A", uuid: "2A24")
    }

    public var serialNumber: Characteristic<String> {
        return Characteristic(peripheral: self, service: "180A", uuid: "2A25")
    }

    public var hardwareRevision: Characteristic<String> {
        return Characteristic(peripheral: self, service: "180A", uuid: "2A27")
    }

    public var firmwareRevision: Characteristic<String> {
        return Characteristic(peripheral: self, service: "180A", uuid: "2A26")
    }
}
