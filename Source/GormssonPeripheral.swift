//
//  GormssonPeripheral.swift
//  Gormsson
//
//  Created by Mac on 03/08/2020.
//  Copyright © 2020 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

public struct GormssonPeripheral: Identifiable {
    public let peripheral: CBPeripheral
    public let advertisement: GattAdvertisement
    public let lastUpdate: Date

    public var id: UUID { peripheral.identifier }

    internal init(peripheral: CBPeripheral, advertisement: GattAdvertisement) {
        self.peripheral = peripheral
        self.advertisement = advertisement
        self.lastUpdate = Date()
    }
}
