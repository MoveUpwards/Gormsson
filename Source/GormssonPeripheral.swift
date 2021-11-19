//
//  GormssonPeripheral.swift
//  Gormsson
//
//  Created by Mac on 03/08/2020.
//  Copyright © 2020 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

public struct GormssonPeripheral {
    public let peripheral: CBPeripheral
    public let advertisement: GattAdvertisement
    public let lastUpdate: Date

    internal init(peripheral: CBPeripheral, advertisement: GattAdvertisement) {
        self.peripheral = peripheral
        self.advertisement = advertisement
        self.lastUpdate = Date()
    }
}

extension GormssonPeripheral: Identifiable {
    public var id: UUID { peripheral.identifier }
}

extension GormssonPeripheral: Equatable {
    public static func == (lhs: GormssonPeripheral, rhs: GormssonPeripheral) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
}
