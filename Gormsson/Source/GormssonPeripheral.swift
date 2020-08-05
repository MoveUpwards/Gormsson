//
//  GormssonPeripheral.swift
//  Gormsson
//
//  Created by Mac on 03/08/2020.
//  Copyright © 2020 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

public struct GormssonPeripheral: Identifiable {
    public private(set) var peripheral: CBPeripheral
    public private(set) var advertisement: GattAdvertisement
    public private(set) var lastUpdate: Date

    public var id: UUID { peripheral.identifier }

    internal init(peripheral: CBPeripheral, advertisement: GattAdvertisement) {
        self.peripheral = peripheral
        self.advertisement = advertisement
        self.lastUpdate = Date()
    }

    internal mutating func update(peripheral: CBPeripheral, advertisement: GattAdvertisement) {
        self.peripheral = peripheral
        self.advertisement = advertisement
        self.lastUpdate = Date()
    }
}
