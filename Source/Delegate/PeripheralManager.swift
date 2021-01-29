//
//  Peripheral.swift
//  Gormsson
//
//  Created by Mac on 05/11/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

internal final class PeripheralManager: NSObject {
    internal weak var manager: CentralManager?

    internal init(_ manager: CentralManager?) {
        super.init()
        self.manager = manager
    }
}
