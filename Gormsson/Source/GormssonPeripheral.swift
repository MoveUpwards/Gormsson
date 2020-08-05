//
//  GormssonPeripheral.swift
//  Gormsson
//
//  Created by Mac on 03/08/2020.
//  Copyright © 2020 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

public class GormssonPeripheral {
    public private(set) var peripheral: CBPeripheral
    public private(set) var advertisement: GattAdvertisement
    internal private(set) var lastUpdate: Date = Date()

    internal init(peripheral: CBPeripheral, advertisement: GattAdvertisement) {
        self.peripheral = peripheral
        self.advertisement = advertisement
    }

    internal func update(peripheral: CBPeripheral, advertisement: GattAdvertisement) {
        self.peripheral = peripheral
        self.advertisement = advertisement
        lastUpdate = Date()
    }
}
