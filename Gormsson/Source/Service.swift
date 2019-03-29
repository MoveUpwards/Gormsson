//
//  GattService.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 29/03/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import RxBluetoothKit
import CoreBluetooth

public struct Service: ServiceIdentifier {
    public var uuid: CBUUID

    public init(uuid: String) {
        self.uuid = CBUUID(string: uuid)
    }
}
